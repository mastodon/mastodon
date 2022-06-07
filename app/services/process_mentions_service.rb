# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include Payloadable

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  # @param [Circle] circle
  def call(status, circle = nil)
    @status = status
    @circle = circle
    return unless @status.local?

    @previous_mentions = @status.active_mentions.includes(:account).to_a
    @current_mentions  = []

    Status.transaction do
      scan_text!
      assign_mentions!
    end
  end

  private

  def scan_text!
    @status.text = @status.text.gsub(Account::MENTION_RE) do |match|
      username, domain = Regexp.last_match(1).split('@')

      domain = begin
        if TagManager.instance.local_domain?(domain)
          nil
        else
          TagManager.instance.normalize_domain(domain)
        end
      end

      mentioned_account = Account.find_remote(username, domain)

      # Unapproved and unconfirmed accounts should not be mentionable
      next if mentioned_account&.local? && !(mentioned_account.user_confirmed? && mentioned_account.user_approved?)

      # If the account cannot be found or isn't the right protocol,
      # first try to resolve it
      if mention_undeliverable?(mentioned_account)
        begin
          mentioned_account = ResolveAccountService.new.call(Regexp.last_match(1))
        rescue Webfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::UnexpectedResponseError
          mentioned_account = nil
        end
      end

      # If after resolving it still isn't found or isn't the right
      # protocol, then give up
      next match if mention_undeliverable?(mentioned_account) || mentioned_account&.suspended?

      mention   = @previous_mentions.find { |x| x.account_id == mentioned_account.id }
      mention ||= mentioned_account.mentions.new(status: @status)

      @current_mentions << mention

      "@#{mentioned_account.acct}"
    end

    mentioned_account_ids = @current_mentions.pluck(:account_id)

    if @circle.present?
      @circle.accounts.find_each do |target_account|
        @status.mentions.find_or_create_by(silent: true, account: target_account) unless mentioned_account_ids.include?(target_account.id)
      end
    elsif @status.limited_visibility? && @status.thread&.limited_visibility?
      # If we are replying to a local status, then we'll have the complete
      # audience copied here, both local and remote. If we are replying
      # to a remote status, only local audience will be copied. Then we
      # need to send our reply to the remote author's inbox for distribution

      @status.thread.mentions.includes(:account).find_each do |mention|
        @status.mentions.create(silent: true, account: mention.account) unless @status.account_id == mention.account_id && mentioned_account_ids.include?(mention.account.id)
      end

      @status.mentions.create(silent: true, account: status.thread.account) unless @status.account_id == @status.thread.account_id && mentioned_account_ids.include?(@status.thread.account.id)
    end

    @status.save!
  end

  def assign_mentions!
    @current_mentions.each do |mention|
      mention.save if mention.new_record?
    end

    # If previous mentions are no longer contained in the text, convert them
    # to silent mentions, since withdrawing access from someone who already
    # received a notification might be more confusing
    removed_mentions = @previous_mentions - @current_mentions

    Mention.where(id: removed_mentions.map(&:id)).update_all(silent: true) unless removed_mentions.empty?
  end

  def mention_undeliverable?(mentioned_account)
    mentioned_account.nil? || (!mentioned_account.local? && !mentioned_account.activitypub?)
  end
end

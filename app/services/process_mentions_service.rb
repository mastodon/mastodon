# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include Payloadable

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  # @param [Circle] circle
  def call(status, circle = nil)
    return unless status.local?

    @status  = status
    mentions = []

    status.text = status.text.gsub(Account::MENTION_RE) do |match|
      username, domain = Regexp.last_match(1).split('@')

      domain = begin
        if TagManager.instance.local_domain?(domain)
          nil
        else
          TagManager.instance.normalize_domain(domain)
        end
      end

      mentioned_account = Account.find_remote(username, domain)

      if mention_undeliverable?(mentioned_account)
        begin
          mentioned_account = resolve_account_service.call(Regexp.last_match(1))
        rescue Webfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::UnexpectedResponseError
          mentioned_account = nil
        end
      end

      next match if mention_undeliverable?(mentioned_account) || mentioned_account&.suspended?

      mention = mentioned_account.mentions.new(status: status)
      mentions << mention if mention.save

      "@#{mentioned_account.acct}"
    end

    mentioned_account_ids = mentions.pluck(:account_id)

    if circle.present?
      circle.accounts.find_each do |target_account|
        status.mentions.find_or_create_by(silent: true, account: target_account) unless mentioned_account_ids.include?(target_account.id)
      end
    elsif status.limited_visibility? && status.thread&.limited_visibility?
      # If we are replying to a local status, then we'll have the complete
      # audience copied here, both local and remote. If we are replying
      # to a remote status, only local audience will be copied. Then we
      # need to send our reply to the remote author's inbox for distribution

      status.thread.mentions.includes(:account).find_each do |mention|
        status.mentions.create(silent: true, account: mention.account) unless status.account_id == mention.account_id && mentioned_account_ids.include?(mention.account.id)
      end

      status.mentions.create(silent: true, account: status.thread.account) unless status.account_id == status.thread.account_id && mentioned_account_ids.include?(status.thread.account.id)
    end

    status.save!

    # Silent mentions need to be delivered separately
    mentions.each { |mention| create_notification(mention) }
  end

  private

  def mention_undeliverable?(mentioned_account)
    mentioned_account.nil? || (!mentioned_account.local? && mentioned_account.ostatus?)
  end

  def create_notification(mention)
    mentioned_account = mention.account

    if mentioned_account.local?
      LocalNotificationWorker.perform_async(mentioned_account.id, mention.id, mention.class.name, :mention)
    elsif mentioned_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(activitypub_json, mention.status.account_id, mentioned_account.inbox_url, { synchronize_followers: !mention.status.distributable? })
    end
  end

  def activitypub_json
    return @activitypub_json if defined?(@activitypub_json)
    @activitypub_json = Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status), ActivityPub::ActivitySerializer, signer: @status.account))
  end

  def resolve_account_service
    ResolveAccountService.new
  end
end

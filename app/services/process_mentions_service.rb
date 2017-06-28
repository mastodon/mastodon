# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include StreamEntryRenderer

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  def call(status)
    return unless status.local?

    status.text.scan(Account::MENTION_RE).each do |match|
      username, domain  = match.first.split('@')
      mentioned_account = Account.find_remote(username, domain)

      if mentioned_account.nil? && !domain.nil?
        begin
          mentioned_account = follow_remote_account_service.call(match.first.to_s)
        rescue Goldfinger::Error, HTTP::Error
          mentioned_account = nil
        end
      end

      next if mentioned_account.nil?

      mentioned_account.mentions.where(status: status).first_or_create(status: status)
    end

    FeedManager.instance.filter_mentions(status).each do |mention|
      NotifyService.new.call(mention.account, mention)
    end

    status.mentions.includes(:account).where.not(accounts: { domain: nil }).each do |mention|
      NotificationWorker.perform_async(stream_entry_to_xml(status.stream_entry), status.account_id, mention.account.id)
    end
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= ResolveRemoteAccountService.new
  end
end

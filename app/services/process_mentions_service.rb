# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include StreamEntryRenderer

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  def call(status)
    return unless status.local?

    text = [status.text, status.spoiler_text].reject(&:blank?).join(' ')

    text.scan(Account::MENTION_RE).each do |match|
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

    status.mentions.includes(:account).each do |mention|
      mentioned_account = mention.account

      if mentioned_account.local?
        NotifyService.new.call(mentioned_account, mention)
      else
        NotificationWorker.perform_async(stream_entry_to_xml(status.stream_entry), status.account_id, mentioned_account.id)
      end
    end
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end
end

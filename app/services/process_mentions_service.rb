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

    status.mentions.includes(:account).each do |mention|
      create_notification(status, mention)
    end
  end

  private

  def create_notification(status, mention)
    mentioned_account = mention.account

    if mentioned_account.local?
      NotifyService.new.call(mentioned_account, mention)
    elsif mentioned_account.ostatus? && (Rails.configuration.x.use_ostatus_privacy || !status.stream_entry.hidden?)
      NotificationWorker.perform_async(stream_entry_to_xml(status.stream_entry), status.account_id, mentioned_account.id)
    elsif mentioned_account.activitypub? && !mentioned_account.following?(status.account)
      ActivityPub::DeliveryWorker.perform_async(build_json(mention.status), mention.status.account_id, mentioned_account.inbox_url)
    end
  end

  def build_json(status)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: ActivityPub::ActivitySerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(status.account))
  end

  def follow_remote_account_service
    @follow_remote_account_service ||= ResolveRemoteAccountService.new
  end
end

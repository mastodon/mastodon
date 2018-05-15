# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  def perform
    original_status   = status_from_uri(object_uri)
    original_status ||= fetch_remote_original_status

    return if original_status.nil? || delete_arrived_first?(@json['id']) || !announceable?(original_status)

    status = Status.find_by(account: @account, reblog: original_status)

    return status unless status.nil?

    status = Status.create!(
      account: @account,
      reblog: original_status,
      uri: @json['id'],
      created_at: @json['published'],
      override_timestamps: @options[:override_timestamps],
      visibility: original_status.visibility
    )

    distribute(status)
    status
  end

  private

  def fetch_remote_original_status
    if object_uri.start_with?('http')
      return if ActivityPub::TagManager.instance.local_uri?(object_uri)

      ActivityPub::FetchRemoteStatusService.new.call(object_uri, id: true, on_behalf_of: @account.followers.local.first)
    elsif @object['url'].present?
      ::FetchRemoteStatusService.new.call(@object['url'])
    end
  end

  def announceable?(status)
    status.account_id == @account.id || status.public_visibility? || status.unlisted_visibility?
  end
end

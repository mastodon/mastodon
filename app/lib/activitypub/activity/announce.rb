# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  def perform
    original_status = status_from_uri(object_uri)
    original_status = ActivityPub::FetchRemoteStatusService.new.call(object_uri) if status.nil?

    return if original_status.nil?

    status = Status.create!(account: @account, reblog: original_status)
    distribute(status)
    status
  end
end

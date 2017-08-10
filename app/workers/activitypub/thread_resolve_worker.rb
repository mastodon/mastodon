# frozen_string_literal: true

class ActivityPub::ThreadResolveWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(child_status_id, parent_uri)
    child_status  = Status.find(child_status_id)
    parent_status = ActivityPub::FetchRemoteStatusService.new.call(parent_uri)

    return if parent_status.nil?

    child_status.thread = parent_status
    child_status.save!
  end
end

# frozen_string_literal: true

class ThreadResolveWorker
  include Sidekiq::Worker

  def perform(child_status_id, parent_url)
    child_status  = Status.find(child_status_id)
    parent_status = FetchRemoteStatusService.new.call(parent_url)

    unless parent_status.nil?
      child_status.thread = parent_status
      child_status.save!
    end
  end
end

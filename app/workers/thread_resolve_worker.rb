# frozen_string_literal: true

class ThreadResolveWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 3

  sidekiq_retry_in do |count|
    15 + 10 * (count**4) + rand(10 * (count**4))
  end

  def perform(child_status_id, parent_url)
    child_status  = Status.find(child_status_id)
    parent_status = FetchRemoteStatusService.new.call(parent_url)

    return if parent_status.nil?

    child_status.thread = parent_status
    child_status.save!
  end
end

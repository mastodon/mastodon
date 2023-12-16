# frozen_string_literal: true

class ThreadResolveWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_status_id, parent_url, options = {})
    child_status  = Status.find(child_status_id)
    parent_status = FetchRemoteStatusService.new.call(parent_url, **options.deep_symbolize_keys)

    return if parent_status.nil?

    child_status.thread = parent_status
    child_status.save!
  rescue ActiveRecord::RecordNotFound
    true
  end
end

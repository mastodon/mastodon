# frozen_string_literal: true

class ThreadResolveWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_status_id, parent_url, options = {})
    child_status = Status.find(child_status_id)
    return if child_status.in_reply_to_id.present?

    skip_fetching = options.delete('skip_fetching')

    parent_status = ActivityPub::TagManager.instance.uri_to_resource(parent_url, Status)
    parent_status ||= FetchRemoteStatusService.new.call(parent_url, **options.deep_symbolize_keys) unless skip_fetching

    if parent_status.nil?
      raise 'presumably private parent not found, retrying later' if skip_fetching

      ThreadResolveWorker.perform_async(child_status_id, parent_url, { 'skip_fetching' => true })
      return
    end

    child_status.thread = parent_status
    child_status.save!

    DistributionWorker.perform_async(child_status_id, { 'skip_notifications' => true }) if child_status.within_realtime_window?
  rescue ActiveRecord::RecordNotFound
    true
  end
end

# frozen_string_literal: true

class ActivityPub::FetchRepliesWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(parent_status_id, replies_uri)
    ActivityPub::FetchRepliesService.new.call(Status.find(parent_status_id), replies_uri)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

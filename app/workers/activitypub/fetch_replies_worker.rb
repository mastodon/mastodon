# frozen_string_literal: true

class ActivityPub::FetchRepliesWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 3

  sidekiq_retry_in do |count|
    15 + 10 * (count**4) + rand(10 * (count**4))
  end

  def perform(parent_status_id, replies_uri)
    ActivityPub::FetchRepliesService.new.call(Status.find(parent_status_id), replies_uri)
  end
end

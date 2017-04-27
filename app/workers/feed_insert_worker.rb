# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  def perform(status_id, follower_id)
    status   = Status.find(status_id)
    follower = Account.find(follower_id)

    return if FeedManager.instance.filter?(:home, status, follower.id)
    FeedManager.instance.push(:home, follower, status)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

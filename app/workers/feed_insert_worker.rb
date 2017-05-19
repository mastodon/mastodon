# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  def perform(status_id, follower_ids)
    status = Status.find_by(id: status_id)
    followers = Account.where(id: follower_ids)

    if records_available?(status, followers)
      perform_push(status, followers)
    else
      true
    end
  end

  private

  def records_available?(status, followers)
    status.present? && followers.present?
  end

  def perform_push(status, followers)
    FeedManager.instance.push(:home, followers, status)
  end
end

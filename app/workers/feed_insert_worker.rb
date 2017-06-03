# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  def perform(status_id, follower_ids)
    status = Status.find_by(id: status_id)
    followers = Account.where(id: follower_ids)

    check_and_insert(status, followers)
  end

  private

  def check_and_insert(status, followers)
    if records_available?(status, followers)
      followers = followers.reject do |follower|
        feed_filtered?(status, follower)
      end

      perform_push(status, followers) unless followers.empty?
    else
      true
    end
  end

  def records_available?(status, followers)
    status.present? && followers.present?
  end

  def feed_filtered?(status, follower)
    FeedManager.instance.filter?(:home, status, follower.id)
  end

  def perform_push(status, followers)
    FeedManager.instance.push(:home, followers, status)
  end
end

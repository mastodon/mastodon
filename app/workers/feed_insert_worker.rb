# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  attr_reader :status, :follower

  def perform(status_id, follower_id)
    @status = Status.find_by(id: status_id)
    @follower = Account.find_by(id: follower_id)

    check_and_insert
  end

  private

  def check_and_insert
    if records_available?
      perform_push unless feed_filtered?
    else
      true
    end
  end

  def records_available?
    status.present? && follower.present?
  end

  def feed_filtered?
    FeedManager.instance.filter?(:home, status, follower.id)
  end

  def perform_push
    FeedManager.instance.push(:home, follower, status)
  end
end

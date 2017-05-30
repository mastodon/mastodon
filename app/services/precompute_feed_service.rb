# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  LIMIT = FeedManager::MAX_ITEMS / 4

  def call(account)
    @account = account
    populate_feed
  end

  private

  attr_reader :account

  def populate_feed
    redis.pipelined do
      statuses.each do |status|
        process_status(status)
      end
    end
  end

  def process_status(status)
    add_status_to_feed(status) unless skip_status?(status)
  end

  def skip_status?(status)
    status.direct_visibility? || status_filtered?(status)
  end

  def add_status_to_feed(status)
    redis.zadd(account_home_key, status.id, status.reblog? ? status.reblog_of_id : status.id)
  end

  def status_filtered?(status)
    FeedManager.instance.filter?(:home, status, account.id)
  end

  def account_home_key
    FeedManager.instance.key(:home, account.id)
  end

  def statuses
    Status.as_home_timeline(account).order(account_id: :desc).limit(LIMIT)
  end

  def redis
    Redis.current
  end
end

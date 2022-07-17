# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker

  def perform(status_id, options = {})
    RedisLock.acquire(redis: Redis.current, key: "distribute:#{status_id}", autorelease: 5.minutes.seconds) do |lock|
      if lock.acquired?
        FanOutOnWriteService.new.call(Status.find(status_id), **options.symbolize_keys)
      else
        raise Mastodon::RaceConditionError
      end
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

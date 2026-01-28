# frozen_string_literal: true

class UnpublishAnnouncementWorker
  include Sidekiq::Worker
  include Redisable

  def perform(announcement_id)
    payload = Oj.dump(event: :'announcement.delete', payload: announcement_id.to_s)

    FeedManager.instance.with_active_accounts do |account|
      with_redis { |redis| redis.publish("timeline:#{account.id}", payload) if redis.exists?("subscribed:timeline:#{account.id}") }
    end
  end
end

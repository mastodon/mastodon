# frozen_string_literal: true

class UnpublishAnnouncementWorker
  include Sidekiq::Worker
  include Redisable

  def perform(announcement_id)
    payload = Oj.dump(event: :'announcement.delete', payload: announcement_id.to_s)

    FeedManager.instance.with_active_accounts do |account|
      streaming_redis.publish("timeline:#{account.id}", payload) if streaming_redis.exists?("subscribed:timeline:#{account.id}")
    end
  end
end

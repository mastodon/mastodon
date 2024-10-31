# frozen_string_literal: true

class UnpublishAnnouncementWorker
  include Sidekiq::Worker
  include Redisable

  def perform(announcement_id)
    payload = Oj.dump(event: :'announcement.delete', payload: announcement_id.to_s)

    FeedManager.instance.with_active_accounts do |account|
      redis.publish("timeline:#{account.id}", payload) if Timeline.subscribed?("timeline:#{account.id}")
    end
  end
end

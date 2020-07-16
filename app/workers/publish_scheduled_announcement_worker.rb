# frozen_string_literal: true

class PublishScheduledAnnouncementWorker
  include Sidekiq::Worker
  include Redisable

  def perform(announcement_id)
    @announcement = Announcement.find(announcement_id)

    refresh_status_ids!

    @announcement.publish! unless @announcement.published?

    payload = InlineRenderer.render(@announcement, nil, :announcement)
    payload = Oj.dump(event: :announcement, payload: payload)

    FeedManager.instance.with_active_accounts do |account|
      redis.publish("timeline:#{account.id}", payload) if redis.exists?("subscribed:timeline:#{account.id}")
    end
  end

  private

  def refresh_status_ids!
    @announcement.status_ids = Status.from_text(@announcement.text).map(&:id)
    @announcement.save
  end
end

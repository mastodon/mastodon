# frozen_string_literal: true

class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    deliver_to_self(status) if status.account.local?
    deliver_to_followers(status)

    return if status.account.silenced? || !status.public_visibility? || status.reblog?

    deliver_to_hashtags(status)

    return if status.reply? && status.in_reply_to_account_id != status.account_id

    deliver_to_public(status)
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering status #{status.id} to author"
    FeedManager.instance.push(:home, status.account, status)
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to followers"

    status.account.followers.where(domain: nil).joins(:user).where('users.current_sign_in_at > ?', 14.days.ago).find_each do |follower|
      next if FeedManager.instance.filter?(:home, status, follower)
      FeedManager.instance.push(:home, follower, status)
    end
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"
    status.tags.find_each do |tag|
      FeedManager.instance.broadcast("hashtag:#{tag.name}", event: 'update', payload: status.id)
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"
    FeedManager.instance.broadcast(:public, event: 'update', payload: status.id)
  end
end

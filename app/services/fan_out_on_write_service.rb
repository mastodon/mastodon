class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    deliver_to_self(status) if status.account.local?
    deliver_to_followers(status)
    deliver_to_mentioned(status)

    return if status.account.silenced?

    deliver_to_hashtags(status)
    deliver_to_public(status)
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering status #{status.id} to author"
    FeedManager.instance.push(:home, status.account, status)
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to followers"

    status.account.followers.find_each do |follower|
      next if !follower.local? || FeedManager.instance.filter?(:home, status, follower)
      FeedManager.instance.push(:home, follower, status)
    end
  end

  def deliver_to_mentioned(status)
    Rails.logger.debug "Delivering status #{status.id} to mentioned accounts"

    status.mentions.includes(:account).each do |mention|
      mentioned_account = mention.account
      next if !mentioned_account.local? || FeedManager.instance.filter?(:mentions, status, mentioned_account)
      FeedManager.instance.push(:mentions, mentioned_account, status)
    end
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"

    status.tags.find_each do |tag|
      FeedManager.instance.broadcast("hashtag:#{tag.name}", type: 'update', id: status.id)
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"
    FeedManager.instance.broadcast(:public, type: 'update', id: status.id)
  end
end

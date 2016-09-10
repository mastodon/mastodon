class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    deliver_to_self(status) if status.account.local?
    deliver_to_followers(status)
    deliver_to_mentioned(status)
  end

  private

  def deliver_to_self(status)
    FeedManager.instance.push(:home, status.account, status)
  end

  def deliver_to_followers(status)
    status.account.followers.each do |follower|
      next if !follower.local? || FeedManager.instance.filter_status?(status, follower)
      FeedManager.instance.push(:home, follower, status)
    end
  end

  def deliver_to_mentioned(status)
    status.mentions.each do |mention|
      mentioned_account = mention.account
      next unless mentioned_account.local?
      FeedManager.instance.push(:mentions, mentioned_account, status)
    end
  end
end

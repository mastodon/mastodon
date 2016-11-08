class PrecomputeFeedService < BaseService
  # Fill up a user's home/mentions feed from DB and return a subset
  # @param [Symbol] type :home or :mentions
  # @param [Account] account
  def call(type, account)
    instant_return = []

    Status.send("as_#{type}_timeline", account).limit(FeedManager::MAX_ITEMS).each do |status|
      next if FeedManager.instance.filter?(type, status, account)
      redis.zadd(FeedManager.instance.key(type, account.id), status.id, status.reblog? ? status.reblog_of_id : status.id)
    end
  end

  private

  def redis
    $redis
  end
end

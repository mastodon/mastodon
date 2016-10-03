class BlockService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    account.block!(target_account)
    clear_mentions(account, target_account)
  end

  private

  def clear_mentions(account, target_account)
    timeline_key = FeedManager.instance.key(:mentions, account.id)

    target_account.statuses.select('id').find_each do |status|
      redis.zrem(timeline_key, status.id)
    end

    FeedManager.instance.broadcast(account.id, type: 'block', id: target_account.id)
  end

  def redis
    $redis
  end
end

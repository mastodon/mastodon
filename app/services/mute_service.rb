# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id
    clear_home_timeline(account, target_account)
    account.mute!(target_account)
  end

  private

  def clear_home_timeline(account, target_account)
    home_key = FeedManager.instance.key(:home, account.id)

    target_account.statuses.select('id').reorder(nil).find_each do |status|
      redis.zrem(home_key, status.id)
    end
  end

  def redis
    Redis.current
  end
end

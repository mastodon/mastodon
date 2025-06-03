# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @account = account
    super(:home, account.id)
  end

  def regenerating?
    redis.hget(redis_regeneration_key, 'status') == 'running'
  rescue Redis::CommandError
    retry if upgrade_redis_key!
  end

  def regeneration_in_progress!
    redis.hset(redis_regeneration_key, { 'status' => 'running' })
    redis.expire(redis_regeneration_key, 1.day.seconds)
  rescue Redis::CommandError
    upgrade_redis_key!
  end

  def regeneration_finished!
    redis.hset(redis_regeneration_key, { 'status' => 'finished' })
    redis.expire(redis_regeneration_key, 1.hour.seconds)
  rescue Redis::CommandError
    retry if upgrade_redis_key!
  end

  private

  def redis_regeneration_key
    @redis_regeneration_key = "account:#{@account.id}:regeneration"
  end

  def upgrade_redis_key!
    if redis.type(redis_regeneration_key) == 'string'
      redis.del(redis_regeneration_key)
      regeneration_in_progress!
      true
    end
  end
end

# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @account = account
    super(:home, account.id)
  end

  def regenerating?
    redis.exists?("account:#{@account.id}:regeneration")
  end

  def regeneration_in_progress!
    redis.set("account:#{@account.id}:regeneration", true, nx: true, ex: 1.day.seconds)
  end

  def regeneration_finished!
    redis.del("account:#{@account.id}:regeneration")
  end
end

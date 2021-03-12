# frozen_string_literal: true

class DirectFeed < Feed
  include Redisable

  def initialize(account)
    @type    = :direct
    @id      = account.id
    @account = account
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    unless redis.exists("account:#{@account.id}:regeneration")
      statuses = super
      return statuses unless statuses.empty?
    end
    from_database(limit, max_id, since_id, min_id)
  end

  private

  def from_database(limit, max_id, since_id, min_id)
    loop do
      statuses = Status.as_direct_timeline(@account, limit, max_id, since_id, min_id)
      return statuses if statuses.empty?
      max_id = statuses.last.id
      statuses = statuses.reject { |status| FeedManager.instance.filter?(:direct, status, @account) }
      return statuses unless statuses.empty?
    end
  end
end

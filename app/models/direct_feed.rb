# frozen_string_literal: true

class DirectFeed < Feed
  include Redisable

  def initialize(account)
    @account = account
    super(:direct, account.id)
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    unless redis.exists("account:#{@account.id}:regeneration")
      statuses = super
      return statuses unless statuses.empty?
    end
    from_database(limit, max_id, since_id, min_id)
  end

  private

  # TODO: _min_id is not actually handled by `as_direct_timeline`
  def from_database(limit, max_id, since_id, _min_id)
    loop do
      statuses = Status.as_direct_timeline(@account, limit, max_id, since_id)
      return statuses if statuses.empty?

      max_id = statuses.last.id
      statuses = statuses.reject { |status| FeedManager.instance.filter?(:direct, status, @account) }
      return statuses unless statuses.empty?
    end
  end
end

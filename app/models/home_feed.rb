# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @type    = :home
    @id      = account.id
    @account = account
  end

  def get(limit, max_id = nil, since_id = nil)
    unless redis.exists("account:#{@account.id}:regeneration")
      statuses = super
      return statuses unless statuses.empty?
    end
    from_database(limit, max_id, since_id)
  end

  private

  def from_database(limit, max_id, since_id)
    loop do
      statuses = Status.as_home_timeline(@account)
                       .paginate_by_max_id(limit, max_id, since_id)
      return statuses if statuses.empty?
      max_id = statuses.last.id
      statuses = statuses.reject { |status| FeedManager.instance.filter?(:home, status, @account.id) }
      return statuses unless statuses.empty?
    end
  end
end

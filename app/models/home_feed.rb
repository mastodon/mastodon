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
    Status.as_home_timeline(@account)
          .paginate_by_max_id(limit, max_id, since_id)
          .reject { |status| FeedManager.instance.filter?(:home, status, @account.id) }
  end
end

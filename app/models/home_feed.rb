# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @type    = :home
    @id      = account.id
    @account = account
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    if redis.exists("account:#{@account.id}:regeneration")
      from_database(limit, max_id, since_id, min_id)
    else
      super
    end
  end

  private

  def from_database(limit, max_id, since_id, min_id)
    Status.as_home_timeline(@account)
          .paginate_by_id(limit, max_id: max_id, since_id: since_id, min_id: min_id)
          .reject { |status| FeedManager.instance.filter?(:home, status, @account.id) }
  end
end

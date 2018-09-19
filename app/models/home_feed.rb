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
    statuses = Status.as_home_timeline(@account)

    statuses = if min_id.blank?
                 statuses.paginate_by_max_id(limit, max_id, since_id)
               else
                 statuses.paginate_by_min_id(limit, min_id)
               end

    statuses.reject { |status| FeedManager.instance.filter?(:home, status, @account.id) }
  end
end

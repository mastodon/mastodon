# frozen_string_literal: true

class Vacuum::FeedsVacuum
  def perform
    vacuum_inactive_home_feeds!
    vacuum_inactive_list_feeds!
    vacuum_inactive_direct_feeds!
  end

  private

  def vacuum_inactive_home_feeds!
    inactive_users.select(:id, :account_id).find_in_batches do |users|
      feed_manager.clean_feeds!(:home, users.map(&:account_id))
    end
  end

  def vacuum_inactive_list_feeds!
    inactive_users_lists.select(:id).find_in_batches do |lists|
      feed_manager.clean_feeds!(:list, lists.map(&:id))
    end
  end

  def vacuum_inactive_direct_feeds!
    inactive_users_lists.select(:id).find_in_batches do |lists|
      feed_manager.clean_feeds!(:direct, lists.map(&:id))
    end
  end

  def inactive_users
    User.confirmed.inactive
  end

  def inactive_users_lists
    List.where(account_id: inactive_users.select(:account_id))
  end

  def feed_manager
    FeedManager.instance
  end
end

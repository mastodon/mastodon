# frozen_string_literal: true

module Vacuum
  class FeedsVacuum
    def perform
      vacuum_inactive_home_feeds!
      vacuum_inactive_list_feeds!
    end

    private

    def vacuum_inactive_home_feeds!
      inactive_users.select(:id, :account_id).in_batches do |users|
        FeedManager.instance.clean_feeds!(:home, users.pluck(:account_id))
      end
    end

    def vacuum_inactive_list_feeds!
      inactive_users_lists.select(:id).in_batches do |lists|
        FeedManager.instance.clean_feeds!(:list, lists.ids)
      end
    end

    def inactive_users
      User.confirmed.inactive
    end

    def inactive_users_lists
      List.where(account_id: inactive_users.select(:account_id))
    end
  end
end

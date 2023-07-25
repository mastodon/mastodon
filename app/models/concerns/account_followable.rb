# frozen_string_literal: true

module AccountFollowable
  extend ActiveSupport::Concern

  included do
    scope :followable_by, ->(account) { without_follows(account).without_follow_requests(account) }
  end

  class_methods do
    def without_follows(account)
      joins(follows_join(account)).where(follows_id_nil)
    end

    def follows_join(account)
      arel_table.join(Follow.arel_table, Arel::Nodes::OuterJoin)
                .on(follows_join_conditions(account))
                .join_sources
    end

    def follows_join_conditions(account)
      arel_table[:id].eq(Follow.arel_table[:target_account_id])
                     .and(Follow.arel_table[:account_id].eq(account.id))
    end

    def follows_id_nil
      Follow.arel_table[:id].eq(nil)
    end

    def without_follow_requests(account)
      joins(follow_requests_join(account)).where(follow_requests_id_nil)
    end

    def follow_requests_join(account)
      arel_table.join(FollowRequest.arel_table, Arel::Nodes::OuterJoin)
                .on(follow_requests_join_conditions(account))
                .join_sources
    end

    def follow_requests_join_conditions(account)
      arel_table[:id].eq(FollowRequest.arel_table[:target_account_id])
                     .and(FollowRequest.arel_table[:account_id].eq(account.id))
    end

    def follow_requests_id_nil
      FollowRequest.arel_table[:id].eq(nil)
    end
  end
end

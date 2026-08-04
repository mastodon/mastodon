# frozen_string_literal: true

# == Schema Information
#
# Table name: global_follow_recommendations
#
#  rank       :decimal(, )      not null
#  reason     :string           not null, is an Array
#  stale      :boolean          default(FALSE), not null
#  account_id :bigint(8)        not null, primary key
#

class FollowRecommendation < ApplicationRecord
  self.primary_key = :account_id
  self.table_name = :global_follow_recommendations

  belongs_to :account_summary, foreign_key: :account_id, inverse_of: false
  belongs_to :account

  scope :unsupressed, -> { where.not(FollowRecommendationSuppression.where(FollowRecommendationSuppression.arel_table[:account_id].eq(arel_table[:account_id])).select(1).arel.exists) }
  scope :localized, ->(locale) { unsupressed.joins(:account_summary).merge(AccountSummary.localized(locale)) }

  def self.refresh
    return unless connection.table_exists?(table_name)

    # TODO: somehow improve performances

    in_batches.update_all(stale: true)

    connection.execute(<<~SQL.squish)
      INSERT INTO global_follow_recommendations (account_id, rank, reason)
        SELECT
          account_id,
          sum(rank) AS rank,
          array_agg(reason) AS reason
        FROM (
          SELECT
            account_summaries.account_id AS account_id,
            count(follows.id) / (1.0 + count(follows.id)) AS rank,
            'most_followed' AS reason
          FROM follows
          INNER JOIN account_summaries ON account_summaries.account_id = follows.target_account_id
          INNER JOIN users ON users.account_id = follows.account_id
          WHERE users.current_sign_in_at >= (now() - interval '30 days')
            AND account_summaries.sensitive = 'f'
            AND NOT EXISTS (SELECT 1 FROM follow_recommendation_suppressions WHERE follow_recommendation_suppressions.account_id = follows.target_account_id)
          GROUP BY account_summaries.account_id
          HAVING count(follows.id) >= 5
          UNION ALL
          SELECT account_summaries.account_id AS account_id,
                sum(status_stats.reblogs_count + status_stats.favourites_count) / (1.0 + sum(status_stats.reblogs_count + status_stats.favourites_count)) AS rank,
                'most_interactions' AS reason
          FROM status_stats
          INNER JOIN statuses ON statuses.id = status_stats.status_id
          INNER JOIN account_summaries ON account_summaries.account_id = statuses.account_id
          WHERE statuses.id >= ((date_part('epoch', now() - interval '30 days') * 1000)::bigint << 16)
            AND account_summaries.sensitive = 'f'
            AND NOT EXISTS (SELECT 1 FROM follow_recommendation_suppressions WHERE follow_recommendation_suppressions.account_id = statuses.account_id)
          GROUP BY account_summaries.account_id
          HAVING sum(status_stats.reblogs_count + status_stats.favourites_count) >= 5
        ) t0
        GROUP BY account_id
        ORDER BY rank DESC
      ON CONFLICT (account_id) DO UPDATE SET rank = EXCLUDED.rank, reason = EXCLUDED.reason, stale = 'f'
    SQL

    where(stale: true).in_batches.delete_all
  end

  def self.readonly?
    true
  end
end

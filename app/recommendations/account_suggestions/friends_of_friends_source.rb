# frozen_string_literal: true

class AccountSuggestions::FriendsOfFriendsSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    source_query(account, limit: limit)
      .map { |id, _frequency, _followers_count| [id, key] }
  end

  def source_query(account, limit: DEFAULT_LIMIT)
    Account.find_by_sql([<<~SQL.squish, { id: account.id, limit: limit }]).map { |row| [row.id, row.frequency, row.followers_count] }
      WITH first_degree AS (
          SELECT target_account_id
          FROM follows
          JOIN accounts AS target_accounts ON follows.target_account_id = target_accounts.id
          WHERE account_id = :id
            AND NOT target_accounts.hide_collections
      )
      SELECT accounts.id, COUNT(*) AS frequency, account_stats.followers_count as followers_count
      FROM accounts
      JOIN follows ON follows.target_account_id = accounts.id
      JOIN account_stats ON account_stats.account_id = accounts.id
      LEFT OUTER JOIN follow_recommendation_mutes ON follow_recommendation_mutes.target_account_id = accounts.id AND follow_recommendation_mutes.account_id = :id
      WHERE follows.account_id IN (SELECT * FROM first_degree)
        AND NOT EXISTS (SELECT 1 FROM blocks b WHERE b.target_account_id = follows.target_account_id AND b.account_id = :id)
        AND NOT EXISTS (SELECT 1 FROM blocks b WHERE b.target_account_id = :id AND b.account_id = follows.target_account_id)
        AND NOT EXISTS (SELECT 1 FROM mutes m WHERE m.target_account_id = follows.target_account_id AND m.account_id = :id)
        AND (accounts.domain IS NULL OR NOT EXISTS (SELECT 1 FROM account_domain_blocks b WHERE b.account_id = :id AND b.domain = accounts.domain))
        AND NOT EXISTS (SELECT 1 FROM follows f WHERE f.target_account_id = follows.target_account_id AND f.account_id = :id)
        AND follows.target_account_id <> :id
        AND accounts.discoverable
        AND accounts.suspended_at IS NULL
        AND accounts.silenced_at IS NULL
        AND accounts.moved_to_account_id IS NULL
        AND accounts.memorial = FALSE
        AND follow_recommendation_mutes.target_account_id IS NULL
      GROUP BY accounts.id, account_stats.id
      ORDER BY frequency DESC, account_stats.followers_count ASC
      LIMIT :limit
    SQL
  end

  private

  def key
    :friends_of_friends
  end
end

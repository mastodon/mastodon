# frozen_string_literal: true

class AccountSuggestions::FriendsOfFriendsSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    source_query(account, limit: limit)
      .map { |id, _frequency, _followers_count| [id, key] }
  end

  def source_query(account, limit: DEFAULT_LIMIT)
    first_degree = account.following.where.not(hide_collections: true).select(:id).reorder(nil)
    base_account_scope(account)
      .joins(:account_stat)
      .joins(:passive_relationships).where(passive_relationships: { account_id: first_degree })
      .group('accounts.id, account_stats.id')
      .reorder(frequency: :desc, followers_count: :desc)
      .limit(limit)
      .pluck(Arel.sql('accounts.id, COUNT(*) AS frequency, followers_count'))
  end

  private

  def key
    :friends_of_friends
  end
end

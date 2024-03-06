# frozen_string_literal: true

class AccountSuggestions::FriendsOfFriendsSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    first_degree = account.following.where.not(hide_collections: true).select(:id).reorder(nil)
    base_account_scope(account)
      .joins(:account_stat)
      .where(id: Follow.where(account_id: first_degree).select(:target_account_id))
      .group('accounts.id, account_stats.id')
      .reorder('frequency DESC, followers_count DESC')
      .limit(limit)
      .pluck(Arel.sql('accounts.id, COUNT(*) AS frequency'))
      .map { |id, _frequency| [id, key] }
  end

  private

  def key
    :friends_of_friends
  end
end

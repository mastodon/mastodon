# frozen_string_literal: true

class AccountSuggestions::PastInteractionsSource < AccountSuggestions::Source
  include Redisable

  def key
    :past_interactions
  end

  def get(account, skip_account_ids: [], limit: 40)
    account_ids = account_ids_for_account(account.id, limit + skip_account_ids.size) - skip_account_ids

    as_ordered_suggestions(
      scope.where(id: account_ids),
      account_ids
    ).take(limit)
  end

  def remove(account, target_account_id)
    redis.zrem("interactions:#{account.id}", target_account_id)
  end

  private

  def scope
    Account.searchable
  end

  def account_ids_for_account(account_id, limit)
    redis.zrevrange("interactions:#{account_id}", 0, limit).map(&:to_i)
  end

  def to_ordered_list_key(account)
    account.id
  end
end

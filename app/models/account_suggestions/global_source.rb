# frozen_string_literal: true

class AccountSuggestions::GlobalSource < AccountSuggestions::Source
  def key
    :global
  end

  def get(account, skip_account_ids: [], limit: 40)
    account_ids = account_ids_for_locale(account.user_locale) - [account.id] - skip_account_ids

    as_ordered_suggestions(
      scope(account).where(id: account_ids),
      account_ids
    ).take(limit)
  end

  def remove(_account, _target_account_id)
    nil
  end

  private

  def scope(account)
    Account.searchable
           .followable_by(account)
           .not_excluded_by_account(account)
           .not_domain_blocked_by_account(account)
  end

  def account_ids_for_locale(locale)
    Redis.current.zrevrange("follow_recommendations:#{locale}", 0, -1).map(&:to_i)
  end

  def to_ordered_list_key(account)
    account.id
  end
end

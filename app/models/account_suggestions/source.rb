# frozen_string_literal: true

class AccountSuggestions::Source
  def get(_account, **kwargs)
    raise NotImplementedError
  end

  protected

  def base_account_scope(account)
    Account.searchable
           .followable_by(account)
           .not_excluded_by_account(account)
           .not_domain_blocked_by_account(account)
           .where.not(id: account.id)
           .joins("LEFT OUTER JOIN follow_recommendation_mutes ON follow_recommendation_mutes.target_account_id = accounts.id AND follow_recommendation_mutes.account_id = #{account.id}").where(follow_recommendation_mutes: { target_account_id: nil })
  end
end

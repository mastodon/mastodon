# frozen_string_literal: true

class AccountSuggestions::FaspSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    return [] unless Mastodon::Feature.fasp_enabled?

    base_account_scope(account).where(id: fasp_follow_recommendations_for(account)).limit(limit).pluck(:id).map do |account_id|
      [account_id, :fasp]
    end
  end

  private

  def fasp_follow_recommendations_for(account)
    Fasp::FollowRecommendation.for_account(account).newest_first.select(:recommended_account_id)
  end
end

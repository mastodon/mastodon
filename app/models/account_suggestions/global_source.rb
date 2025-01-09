# frozen_string_literal: true

class AccountSuggestions::GlobalSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    FollowRecommendation.localized(content_locale).joins(:account).merge(base_account_scope(account)).order(rank: :desc).limit(limit).pluck(:account_id, :reason)
  end

  private

  def content_locale
    I18n.locale.to_s.split(/[_-]/).first
  end
end

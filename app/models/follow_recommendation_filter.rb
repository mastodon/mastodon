# frozen_string_literal: true

class FollowRecommendationFilter
  include Redisable

  KEYS = %i(
    language
    status
  ).freeze

  attr_reader :params, :language

  def initialize(params)
    @language = usable_language(params.delete('language') || I18n.locale)
    @params   = params
  end

  def results
    if params['status'] == 'suppressed'
      Account.includes(:account_stat).joins(:follow_recommendation_suppression).order(FollowRecommendationSuppression.arel_table[:id].desc)
    else
      Account.includes(:account_stat).joins(:follow_recommendation).merge(FollowRecommendation.localized(@language).order(rank: :desc))
    end
  end

  private

  def usable_language(locale)
    return locale if Trends.available_locales.include?(locale)

    locale = locale.to_s.split(/[_-]/).first
    return locale if Trends.available_locales.include?(locale)

    nil
  end
end

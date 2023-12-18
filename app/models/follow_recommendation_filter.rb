# frozen_string_literal: true

class FollowRecommendationFilter
  include Redisable

  KEYS = %i(
    language
    status
  ).freeze

  attr_reader :params, :language

  def initialize(params)
    @language = params.delete('language') || I18n.locale
    @params   = params
  end

  def results
    if params['status'] == 'suppressed'
      Account.includes(:account_stat).joins(:follow_recommendation_suppression).order(FollowRecommendationSuppression.arel_table[:id].desc)
    else
      Account.includes(:account_stat).joins(:follow_recommendation).merge(FollowRecommendation.localized(@language).order(rank: :desc))
    end
  end
end

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
      Account.joins(:follow_recommendation_suppression).order(FollowRecommendationSuppression.arel_table[:id].desc).to_a
    else
      FollowRecommendation.includes(:account).localized(@language).order(rank: :desc).map(&:account)
    end
  end
end

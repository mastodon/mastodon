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
      account_ids = redis.zrevrange("follow_recommendations:#{@language}", 0, -1).map(&:to_i)
      accounts    = Account.where(id: account_ids).index_by(&:id)

      account_ids.filter_map { |id| accounts[id] }
    end
  end
end

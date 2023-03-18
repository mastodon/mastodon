# frozen_string_literal: true

# == Schema Information
#
# Table name: follow_recommendation_suppressions
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FollowRecommendationSuppression < ApplicationRecord
  include Redisable

  belongs_to :account

  after_commit :remove_follow_recommendations, on: :create

  private

  def remove_follow_recommendations
    redis.pipelined do |pipeline|
      I18n.available_locales.each do |locale|
        pipeline.zrem("follow_recommendations:#{locale}", account_id)
      end
    end
  end
end

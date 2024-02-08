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
  belongs_to :account
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: follow_recommendation_mutes
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class FollowRecommendationMute < ApplicationRecord
  include RecommendationMaintenance

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :target_account_id, uniqueness: { scope: :account_id }
end

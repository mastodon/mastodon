# frozen_string_literal: true

# == Schema Information
#
# Table name: global_follow_recommendations
#
#  account_id :bigint(8)        primary key
#  rank       :decimal(, )
#  reason     :text             is an Array
#

class FollowRecommendation < ApplicationRecord
  include DatabaseViewRecord

  self.primary_key = :account_id
  self.table_name = :global_follow_recommendations

  belongs_to :account_summary, foreign_key: :account_id, inverse_of: false
  belongs_to :account

  scope :unsupressed, -> { where.not(FollowRecommendationSuppression.where(FollowRecommendationSuppression.arel_table[:account_id].eq(arel_table[:account_id])).select(1).arel.exists) }
  scope :localized, ->(locale) { unsupressed.joins(:account_summary).merge(AccountSummary.localized(locale)) }
end

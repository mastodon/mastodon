# frozen_string_literal: true
# == Schema Information
#
# Table name: follow_recommendations
#
#  account_id :bigint(8)        primary key
#  rank       :decimal(, )
#  reason     :text             is an Array
#

class FollowRecommendation < ApplicationRecord
  self.primary_key = :account_id

  belongs_to :account_summary, foreign_key: :account_id
  belongs_to :account, foreign_key: :account_id

  scope :localized, ->(locale) { joins(:account_summary).merge(AccountSummary.localized(locale)) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end
end

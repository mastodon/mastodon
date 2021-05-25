# frozen_string_literal: true
# == Schema Information
#
# Table name: account_summaries
#
#  account_id :bigint(8)        primary key
#  language   :string
#  sensitive  :boolean
#

class AccountSummary < ApplicationRecord
  self.primary_key = :account_id

  scope :safe, -> { where(sensitive: false) }
  scope :localized, ->(locale) { where(language: locale) }
  scope :filtered, -> { joins(arel_table.join(FollowRecommendationSuppression.arel_table, Arel::Nodes::OuterJoin).on(arel_table[:account_id].eq(FollowRecommendationSuppression.arel_table[:account_id])).join_sources).where(FollowRecommendationSuppression.arel_table[:id].eq(nil)) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end
end

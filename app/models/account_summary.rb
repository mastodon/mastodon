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

  has_many :follow_recommendation_suppressions, primary_key: :account_id, foreign_key: :account_id, inverse_of: false

  scope :safe, -> { where(sensitive: false) }
  scope :localized, ->(locale) { order(Arel::Nodes::Case.new.when(arel_table[:language].eq(locale)).then(1).else(0).desc) }
  scope :filtered, -> { where.missing(:follow_recommendation_suppressions) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  rescue ActiveRecord::StatementInvalid
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end
end

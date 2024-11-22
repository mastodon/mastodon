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
  include DatabaseViewRecord

  self.primary_key = :account_id

  has_many :follow_recommendation_suppressions, primary_key: :account_id, foreign_key: :account_id, inverse_of: false, dependent: nil

  scope :safe, -> { where(sensitive: false) }
  scope :localized, ->(locale) { order(Arel::Nodes::Case.new.when(arel_table[:language].eq(locale)).then(1).else(0).desc) }
  scope :filtered, -> { where.missing(:follow_recommendation_suppressions) }
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: account_summaries
#
#  language   :string
#  sensitive  :boolean
#  account_id :bigint(8)        primary key
#

class AccountSummary < ApplicationRecord
  include DatabaseViewRecord

  self.primary_key = :account_id

  has_many :follow_recommendation_suppressions, primary_key: :account_id, foreign_key: :account_id, inverse_of: false, dependent: nil

  scope :safe, -> { where(sensitive: false) }
  scope :localized, ->(locale) { in_order_of(:language, [locale], filter: false) }
  scope :filtered, -> { where.missing(:follow_recommendation_suppressions) }
end

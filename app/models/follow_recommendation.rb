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

  scope :safe, -> { joins(:account_summary).merge(AccountSummary.safe) }
  scope :localized, ->(locale) { joins(:account_summary).merge(AccountSummary.localized(locale)) }
  scope :filtered, -> { joins(:account_summary).merge(AccountSummary.filtered) }

  def readonly?
    true
  end
end

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

  def self.get(account, limit, exclude_account_ids = [])
    account_ids = Redis.current.zrevrange("follow_recommendations:#{account.user_locale}", 0, -1).map(&:to_i) - exclude_account_ids - [account.id]

    return [] if account_ids.empty? || limit < 1

    accounts = Account.followable_by(account)
                      .not_excluded_by_account(account)
                      .not_domain_blocked_by_account(account)
                      .where(id: account_ids)
                      .limit(limit)
                      .index_by(&:id)

    account_ids.map { |id| accounts[id] }.compact
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: emergency_rate_limit_actions
#
#  id                :bigint(8)        not null, primary key
#  emergency_rule_id :bigint(8)        not null
#  new_users_only    :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Emergency::RateLimitAction < ApplicationRecord
  belongs_to :emergency_rule, class_name: 'Emergency::Rule', inverse_of: :rate_limit_actions

  FAMILIES = {
    follows: {
      limit: 10,
      period: 1.hour.freeze,
    }.freeze,

    statuses: {
      limit: 1,
      period: 5.minutes.freeze,
    }.freeze,

    reports: {
      limit: 1,
      period: 10.minutes.freeze,
    }.freeze,
  }.freeze

  after_commit :invalidate_cache!

  class << self
    def get_rate_limits_for(family, by, last_epoch_time)
      return unless by.is_a?(Account) && by.user.present?

      # Cache a compact representation of the rate limits so we can save queries to the cache
      records = Rails.cache.fetch('emergency_rate_limits:cache') do
        all.map { |action| [action.id, action.emergency_rule_id, action.new_users_only?] }
      end

      return if records.nil?

      rules_triggered_at = Emergency::Rule.triggered_at(records.map(&:second))

      records.zip(rules_triggered_at).filter_map do |(action_id, _, new_users_only), triggered_at|
        next if triggered_at.nil? # Skip inactive rules
        next if new_users_only && (by.user.confirmed_at.nil? || triggered_at > by.user.confirmed_at)

        {
          limit: FAMILIES[family][:limit],
          period: FAMILIES[family][:period].to_i,
          key: "emergency_rate_limit:#{action_id}:#{by.id}:#{family}:#{(last_epoch_time / FAMILIES[family][:period].to_i).to_i}",
        }
      end
    end
  end

  private

  def invalidate_cache!
    Rails.cache.delete('emergency_rate_limits:cache')
  end
end

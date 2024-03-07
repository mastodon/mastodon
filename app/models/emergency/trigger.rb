# frozen_string_literal: true

# == Schema Information
#
# Table name: emergency_triggers
#
#  id                :bigint(8)        not null, primary key
#  emergency_rule_id :bigint(8)        not null
#  event             :string           not null
#  threshold         :integer          not null
#  duration_bucket   :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Emergency::Trigger < ApplicationRecord
  belongs_to :emergency_rule, class_name: 'Emergency::Rule', inverse_of: :triggers

  validates :event, inclusion: { in: %w(local:signups local:confirmations local:posts) }

  enum duration_bucket: {
    minute: 0,
    hour: 1,
    day: 2,
  }

  after_commit :invalidate_thresholds_cache!

  class << self
    def process_event(event, at_time, counts)
      # If we haven't reached the lowest threshold, we can avoid database queries
      return if thresholds(event).none? { |bucket, threshold| counts[bucket.to_sym] && counts[bucket.to_sym] >= threshold }

      scope = none
      counts.each do |key, count|
        scope = scope.or(where(event: event, duration_bucket: key, threshold: ..count))
      end

      scope.joins(:emergency_rule).to_a.group_by(&:emergency_rule).each do |rule, triggers|
        event_time = triggers.map(&:duration_bucket).map do |bucket|
          case bucket.to_sym
          when :minute
            at_time.beginning_of_minute
          when :hour
            at_time.beginning_of_hour
          when :day
            at_time.beginning_of_day
          end
        end.min

        rule.trigger!(event_time)
      end
    end

    def thresholds(event)
      Rails.cache.fetch("emergency_rules:triggers:thresholds:#{event}") do
        Emergency::Trigger.where(event: event).group(:duration_bucket).minimum(:threshold)
      end
    end
  end

  private

  def invalidate_thresholds_cache!
    Rails.cache.delete("emergency_rules:triggers:thresholds:#{event}")
  end
end

# frozen_string_literal: true

class Admin::Metrics::Measure::ActiveUsersMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'active_users'
  end

  protected

  def perform_total_query
    activity_tracker.sum(time_period.first, time_period.last)
  end

  def perform_previous_total_query
    activity_tracker.sum(previous_time_period.first, previous_time_period.last)
  end

  def perform_data_query
    activity_tracker.get(time_period.first, time_period.last).map { |date, value| { date: date.to_time(:utc).iso8601, value: value.to_s } }
  end

  def activity_tracker
    @activity_tracker ||= ActivityTracker.new('activity:logins', :unique)
  end
end

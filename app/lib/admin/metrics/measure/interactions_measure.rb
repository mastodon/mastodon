# frozen_string_literal: true

class Admin::Metrics::Measure::InteractionsMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'interactions'
  end

  def total
    activity_tracker.sum(time_period.first, time_period.last)
  end

  def previous_total
    activity_tracker.sum(previous_time_period.first, previous_time_period.last)
  end

  def data
    activity_tracker.get(time_period.first, time_period.last).map { |date, value| { date: date.to_time(:utc).iso8601, value: value.to_s } }
  end

  protected

  def activity_tracker
    @activity_tracker ||= ActivityTracker.new('activity:interactions', :basic)
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end
end

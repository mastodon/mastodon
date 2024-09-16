# frozen_string_literal: true

class Admin::Metrics::Measure::ResolvedReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def key
    'resolved_reports'
  end

  protected

  def perform_total_query
    Report.resolved.where(action_taken_at: time_period).count
  end

  def perform_previous_total_query
    Report.resolved.where(action_taken_at: previous_time_period).count
  end

  def data_source
    Report
      .select(:id)
      .where(matching_day(Report, :action_taken_at))
  end
end

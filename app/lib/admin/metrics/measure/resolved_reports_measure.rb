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

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at }]
  end

  def data_source_query
    Report
      .select(:id)
      .where(
        <<~SQL.squish
          DATE_TRUNC('day', reports.action_taken_at)::date = axis.period
        SQL
      ).to_sql
  end
end

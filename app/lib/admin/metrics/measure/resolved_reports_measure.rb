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

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH resolved_reports AS (
          SELECT reports.id
          FROM reports
          WHERE date_trunc('day', reports.action_taken_at)::date = axis.period
        )
        SELECT count(*) FROM resolved_reports
      ) AS value
      FROM (
        #{generated_series_days}
      ) AS axis
    SQL
  end
end

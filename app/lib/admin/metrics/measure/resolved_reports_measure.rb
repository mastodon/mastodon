# frozen_string_literal: true

class Admin::Metrics::Measure::ResolvedReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'resolved_reports'
  end

  def total
    Report.resolved.where(action_taken_at: time_period).count
  end

  def previous_total
    Report.resolved.where(action_taken_at: previous_time_period).count
  end

  def data
    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH resolved_reports AS (
          SELECT reports.id
          FROM reports
          WHERE date_trunc('day', reports.action_taken_at)::date = axis.period
        )
        SELECT count(*) FROM resolved_reports
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', $1::timestamp)::date, date_trunc('day', $2::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at]])

    rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end
end

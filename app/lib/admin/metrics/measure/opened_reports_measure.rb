# frozen_string_literal: true

class Admin::Metrics::Measure::OpenedReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'opened_reports'
  end

  def total
    Report.where(created_at: time_period).count
  end

  def previous_total
    Report.where(created_at: previous_time_period).count
  end

  def data
    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH new_reports AS (
          SELECT reports.id
          FROM reports
          WHERE date_trunc('day', reports.created_at)::date = axis.period
        )
        SELECT count(*) FROM new_reports
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', $1::timestamp)::date, date_trunc('day', $2::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at]])

    rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end
end

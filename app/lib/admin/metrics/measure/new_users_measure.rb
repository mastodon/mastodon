# frozen_string_literal: true

class Admin::Metrics::Measure::NewUsersMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'new_users'
  end

  def total
    User.where(created_at: time_period).count
  end

  def previous_total
    User.where(created_at: previous_time_period).count
  end

  def data
    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH new_users AS (
          SELECT users.id
          FROM users
          WHERE date_trunc('day', users.created_at)::date = axis.period
        )
        SELECT count(*) FROM new_users
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', $1::timestamp)::date, date_trunc('day', $2::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at]])

    rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end
end

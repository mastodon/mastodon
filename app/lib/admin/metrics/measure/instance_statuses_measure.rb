# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceStatusesMeasure < Admin::Metrics::Measure::BaseMeasure
  def self.with_params?
    true
  end

  def key
    'instance_statuses'
  end

  def total_in_time_range?
    false
  end

  protected

  def perform_total_query
    Status.joins(:account).merge(Account.where(domain: params[:domain])).count
  end

  def perform_previous_total_query
    nil
  end

  def perform_data_query
    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH new_statuses AS (
          SELECT statuses.id
          FROM statuses
          INNER JOIN accounts ON accounts.id = statuses.account_id
          WHERE statuses.id BETWEEN $3 AND $4
            AND accounts.domain = $5::text
            AND date_trunc('day', statuses.created_at)::date = axis.period
        )
        SELECT count(*) FROM new_statuses
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', $1::timestamp)::date, date_trunc('day', $2::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at], [nil, Mastodon::Snowflake.id_at(@start_at, with_random: false)], [nil, Mastodon::Snowflake.id_at(@end_at, with_random: false)], [nil, params[:domain]]])

    rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end

  def params
    @params.permit(:domain)
  end
end

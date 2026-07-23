# frozen_string_literal: true

class Admin::Metrics::Measure::NewUsersMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def key
    'new_users'
  end

  protected

  def perform_total_query
    User.where(created_at: time_period).count
  end

  def perform_previous_total_query
    User.where(created_at: previous_time_period).count
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH new_users AS (
          SELECT users.id
          FROM users
          WHERE users.account_id >= (date_part('epoch', date_trunc('day', axis.period)::date) * 1000)::bigint << 16 AND users.account_id < ((date_part('epoch', date_trunc('day', axis.period)::date + ('1 day')::interval)) * 1000)::bigint << 16
        )
        SELECT count(*) FROM new_users
      ) AS value
      FROM (
        #{generated_series_days}
      ) AS axis
    SQL
  end
end

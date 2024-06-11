# frozen_string_literal: true

module Admin::Metrics::Measure::QueryHelper
  protected

  def perform_data_query
    measurement_data_rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end

  def measurement_data_rows
    ActiveRecord::Base.connection.select_all(sanitized_sql_string)
  end

  def sanitized_sql_string
    ActiveRecord::Base.sanitize_sql_array(sql_array)
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH data_source AS (#{data_source_query.to_sql})
        SELECT #{select_target} FROM data_source
      ) AS value
      FROM (
        SELECT generate_series(:start_at::timestamp, :end_at::timestamp, '1 day')::date AS period
      ) AS axis
    SQL
  end

  def select_target
    <<~SQL.squish
      COUNT(*)
    SQL
  end

  def daily_period(table, column = :created_at)
    <<~SQL.squish
      DATE_TRUNC('day', #{table}.#{column})::date = axis.period
    SQL
  end

  def status_range_sql
    <<~SQL.squish
      statuses.id BETWEEN :earliest_status_id AND :latest_status_id
    SQL
  end

  def account_domain_sql
    if params[:include_subdomains]
      <<~SQL.squish
        accounts.domain IN (SELECT domain FROM instances WHERE reverse('.' || domain) LIKE reverse('.' || :domain::text))
      SQL
    else
      <<~SQL.squish
        accounts.domain = :domain::text
      SQL
    end
  end
end

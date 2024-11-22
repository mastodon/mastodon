# frozen_string_literal: true

class Admin::Metrics::Retention
  CACHE_TTL = 5.minutes.freeze

  class Cohort < ActiveModelSerializers::Model
    attributes :period, :frequency, :data
  end

  class CohortData < ActiveModelSerializers::Model
    attributes :date, :rate, :value
  end

  attr_reader :loaded

  alias loaded? loaded

  def initialize(start_at, end_at, frequency)
    @start_at  = start_at&.to_date
    @end_at    = end_at&.to_date
    @frequency = %w(day month).include?(frequency) ? frequency : 'day'
    @loaded    = false
  end

  def cache_key
    ['metrics/retention', @start_at, @end_at, @frequency].join(';')
  end

  def cohorts
    load
  end

  protected

  def load
    unless loaded?
      @values = Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { perform_query }
      @loaded = true
    end

    @values
  end

  def perform_query
    report_rows.each_with_object([]) do |row, arr|
      current_cohort = arr.last

      if current_cohort.nil? || current_cohort.period != row['cohort_period']
        current_cohort = Cohort.new(period: row['cohort_period'], frequency: @frequency, data: [])
        arr << current_cohort
      end

      value, rate = row['retention_value_and_rate'].delete('{}').split(',')

      current_cohort.data << CohortData.new(
        date: row['retention_period'],
        rate: rate.to_f,
        value: value.to_s
      )
    end
  end

  def report_rows
    ActiveRecord::Base.connection.select_all(sanitized_sql_string)
  end

  def sanitized_sql_string
    ActiveRecord::Base.sanitize_sql_array(
      [sql_query_string, { start_at: @start_at, end_at: @end_at, frequency: @frequency }]
    )
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH new_users AS (
          SELECT users.id
          FROM users
          WHERE date_trunc(:frequency, users.created_at)::date = axis.cohort_period
        ),
        retained_users AS (
          SELECT users.id
          FROM users
          INNER JOIN new_users on new_users.id = users.id
          WHERE date_trunc(:frequency, users.current_sign_in_at) >= axis.retention_period
        )
        SELECT ARRAY[count(*), (count(*))::float / (SELECT GREATEST(count(*), 1) FROM new_users)] AS retention_value_and_rate
        FROM retained_users
      )
      FROM (
        WITH cohort_periods AS (
          SELECT generate_series(date_trunc(:frequency, :start_at::timestamp)::date, date_trunc(:frequency, :end_at::timestamp)::date, ('1 ' || :frequency)::interval) AS cohort_period
        ),
        retention_periods AS (
          SELECT cohort_period AS retention_period FROM cohort_periods
        )
        SELECT *
        FROM cohort_periods, retention_periods
        WHERE retention_period >= cohort_period
      ) as axis
    SQL
  end
end

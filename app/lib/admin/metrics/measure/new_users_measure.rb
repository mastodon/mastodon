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

  def data_source_query
    User
      .select(:id)
      .where(daily_period(:users))
      .to_sql
  end
end

# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceStatusesMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

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
    domain = params[:domain]
    domain = Instance.by_domain_and_subdomains(params[:domain]).select(:domain) if params[:include_subdomains]
    Status.joins(:account).merge(Account.where(domain: domain)).count
  end

  def perform_previous_total_query
    nil
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, domain: params[:domain], earliest_status_id: earliest_status_id, latest_status_id: latest_status_id }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH new_statuses AS (
          SELECT statuses.id
          FROM statuses
          INNER JOIN accounts ON accounts.id = statuses.account_id
          WHERE statuses.id BETWEEN :earliest_status_id AND :latest_status_id
            AND #{account_domain_sql(params[:include_subdomains])}
            AND date_trunc('day', statuses.created_at)::date = axis.period
        )
        SELECT count(*) FROM new_statuses
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', :start_at::timestamp)::date, date_trunc('day', :end_at::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL
  end

  def earliest_status_id
    Mastodon::Snowflake.id_at(@start_at.beginning_of_day, with_random: false)
  end

  def latest_status_id
    Mastodon::Snowflake.id_at(@end_at.end_of_day, with_random: false)
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end

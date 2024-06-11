# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceFollowersMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def self.with_params?
    true
  end

  def key
    'instance_followers'
  end

  def total_in_time_range?
    false
  end

  protected

  def perform_total_query
    domain = params[:domain]
    domain = Instance.by_domain_and_subdomains(params[:domain]).select(:domain) if params[:include_subdomains]
    Follow.joins(:account).merge(Account.where(domain: domain)).count
  end

  def perform_previous_total_query
    nil
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, domain: params[:domain] }]
  end

  def data_source_query
    Follow
      .select(:id)
      .joins(:account)
      .where(account_domain_sql(params[:include_subdomains]))
      .where(daily_period(:follows))
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end

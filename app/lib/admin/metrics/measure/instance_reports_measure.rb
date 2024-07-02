# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def self.with_params?
    true
  end

  def key
    'instance_reports'
  end

  def total_in_time_range?
    false
  end

  protected

  def perform_total_query
    domain = params[:domain]
    domain = Instance.by_domain_and_subdomains(params[:domain]).select(:domain) if params[:include_subdomains]
    Report.where(target_account: Account.where(domain: domain)).count
  end

  def perform_previous_total_query
    nil
  end

  def data_source
    Report
      .select(:id)
      .joins(:target_account)
      .where(account_domain_sql, domain: params[:domain])
      .where(daily_period(:reports))
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end

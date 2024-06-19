# frozen_string_literal: true

class Admin::Metrics::Measure::OpenedReportsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def key
    'opened_reports'
  end

  protected

  def perform_total_query
    Report.where(created_at: time_period).count
  end

  def perform_previous_total_query
    Report.where(created_at: previous_time_period).count
  end

  def data_source
    Report
      .select(:id)
      .where(daily_period(:reports))
  end
end

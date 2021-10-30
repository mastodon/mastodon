# frozen_string_literal: true

class Admin::Metrics::Measure
  MEASURES = {
    active_users: Admin::Metrics::Measure::ActiveUsersMeasure,
    new_users: Admin::Metrics::Measure::NewUsersMeasure,
    interactions: Admin::Metrics::Measure::InteractionsMeasure,
    opened_reports: Admin::Metrics::Measure::OpenedReportsMeasure,
    resolved_reports: Admin::Metrics::Measure::ResolvedReportsMeasure,
    tag_accounts: Admin::Metrics::Measure::TagAccountsMeasure,
    tag_uses: Admin::Metrics::Measure::TagUsesMeasure,
    tag_servers: Admin::Metrics::Measure::TagServersMeasure,
  }.freeze

  def self.retrieve(measure_keys, start_at, end_at, params)
    Array(measure_keys).map { |key| MEASURES[key.to_sym]&.new(start_at, end_at, params[key.to_sym]) }.compact
  end
end

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
    instance_accounts: Admin::Metrics::Measure::InstanceAccountsMeasure,
    instance_media_attachments: Admin::Metrics::Measure::InstanceMediaAttachmentsMeasure,
    instance_reports: Admin::Metrics::Measure::InstanceReportsMeasure,
    instance_statuses: Admin::Metrics::Measure::InstanceStatusesMeasure,
    instance_follows: Admin::Metrics::Measure::InstanceFollowsMeasure,
    instance_followers: Admin::Metrics::Measure::InstanceFollowersMeasure,
  }.freeze

  def self.retrieve(measure_keys, start_at, end_at, params)
    Array(measure_keys).map do |key|
      klass = MEASURES[key.to_sym]
      klass&.new(start_at, end_at, klass.with_params? ? params.require(key.to_sym) : nil)
    end.compact
  end
end

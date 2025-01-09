# frozen_string_literal: true

class Admin::Metrics::Measure
  MEASURES = {
    active_users: ActiveUsersMeasure,
    new_users: NewUsersMeasure,
    interactions: InteractionsMeasure,
    opened_reports: OpenedReportsMeasure,
    resolved_reports: ResolvedReportsMeasure,
    tag_accounts: TagAccountsMeasure,
    tag_uses: TagUsesMeasure,
    tag_servers: TagServersMeasure,
    instance_accounts: InstanceAccountsMeasure,
    instance_media_attachments: InstanceMediaAttachmentsMeasure,
    instance_reports: InstanceReportsMeasure,
    instance_statuses: InstanceStatusesMeasure,
    instance_follows: InstanceFollowsMeasure,
    instance_followers: InstanceFollowersMeasure,
  }.freeze

  def self.retrieve(measure_keys, start_at, end_at, params)
    Array(measure_keys).filter_map do |key|
      klass = MEASURES[key.to_sym]
      klass&.new(start_at, end_at, klass.with_params? ? params.require(key.to_sym) : nil)
    end
  end
end

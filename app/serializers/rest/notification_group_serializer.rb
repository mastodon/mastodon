# frozen_string_literal: true

class REST::NotificationGroupSerializer < ActiveModel::Serializer
  # Please update app/javascript/api_types/notification.ts when making changes to the attributes
  attributes :group_key, :notifications_count, :type, :most_recent_notification_id

  attribute :page_min_id, if: :paginated?
  attribute :page_max_id, if: :paginated?
  attribute :latest_page_notification_at, if: :paginated?

  has_many :sample_accounts, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer
  belongs_to :report, if: :report_type?, serializer: REST::ReportSerializer
  belongs_to :account_relationship_severance_event, key: :event, if: :relationship_severance_event?, serializer: REST::AccountRelationshipSeveranceEventSerializer
  belongs_to :account_warning, key: :moderation_warning, if: :moderation_warning_event?, serializer: REST::AccountWarningSerializer

  def status_type?
    [:favourite, :reblog, :status, :mention, :poll, :update].include?(object.type)
  end

  def report_type?
    object.type == :'admin.report'
  end

  def relationship_severance_event?
    object.type == :severed_relationships
  end

  def moderation_warning_event?
    object.type == :moderation_warning
  end

  def page_min_id
    range = instance_options[:group_metadata][object.group_key]
    range.present? ? range[:min_id].to_s : object.notification.id.to_s
  end

  def page_max_id
    range = instance_options[:group_metadata][object.group_key]
    range.present? ? range[:max_id].to_s : object.notification.id.to_s
  end

  def latest_page_notification_at
    range = instance_options[:group_metadata][object.group_key]
    range.present? ? range[:latest_notification_at] : object.notification.created_at
  end

  def paginated?
    !instance_options[:group_metadata].nil?
  end
end

# frozen_string_literal: true

class REST::NotificationGroupSerializer < ActiveModel::Serializer
  attributes :group_key, :notifications_count, :type

  has_many :sample_accounts, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer
  belongs_to :report, if: :report_type?, serializer: REST::ReportSerializer
  belongs_to :account_relationship_severance_event, key: :event, if: :relationship_severance_event?, serializer: REST::AccountRelationshipSeveranceEventSerializer

  def status_type?
    [:favourite, :reblog, :status, :mention, :poll, :update].include?(object.type)
  end

  def report_type?
    object.type == :'admin.report'
  end

  def relationship_severance_event?
    object.type == :severed_relationships
  end

  # TODO: most recent and/or oldest notification ID
end

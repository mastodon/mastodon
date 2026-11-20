# frozen_string_literal: true

class REST::Admin::ReportSerializer < ActiveModel::Serializer
  attributes :id, :action_taken, :action_taken_at, :category, :comment,
             :forwarded, :created_at, :updated_at

  has_one :account, serializer: REST::Admin::AccountSerializer
  has_one :target_account, serializer: REST::Admin::AccountSerializer
  has_one :assigned_account, serializer: REST::Admin::AccountSerializer
  has_one :action_taken_by_account, serializer: REST::Admin::AccountSerializer

  has_many :statuses, serializer: REST::StatusSerializer
  has_many :rules, serializer: REST::RuleSerializer

  def id
    object.id.to_s
  end

  def statuses
    instance_options[:report_statuses]&.fetch(object.id) { object.statuses.with_includes } || object.statuses.with_includes
  end

  def rules
    instance_options[:report_rules]&.fetch(object.id) { object.rules } || object.rules
  end
end

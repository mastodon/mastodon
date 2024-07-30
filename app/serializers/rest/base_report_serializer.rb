# frozen_string_literal: true

class REST::BaseReportSerializer < ActiveModel::Serializer
  attributes :id, :action_taken, :action_taken_at, :category, :comment,
             :forwarded, :created_at, :status_ids, :rule_ids

  def id
    object.id.to_s
  end

  def status_ids
    object&.status_ids&.map(&:to_s)
  end

  def rule_ids
    object&.rule_ids&.map(&:to_s)
  end
end

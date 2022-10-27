# frozen_string_literal: true

class REST::ReportSerializer < ActiveModel::Serializer
  attributes :id, :action_taken, :action_taken_at, :category, :comment,
             :forwarded, :created_at, :status_ids, :rule_ids

  has_one :target_account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end

# frozen_string_literal: true

class REST::AccountWarningSerializer < ActiveModel::Serializer
  attributes :id, :action, :text, :status_ids, :created_at

  has_one :target_account, serializer: REST::AccountSerializer
  has_one :appeal, serializer: REST::AppealSerializer

  def id
    object.id.to_s
  end

  def status_ids
    object&.status_ids&.map(&:to_s)
  end
end

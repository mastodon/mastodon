# frozen_string_literal: true

class REST::BaseAccountWarningSerializer < ActiveModel::Serializer
  attributes :id, :action, :text, :status_ids, :created_at

  has_one :appeal, serializer: REST::AppealSerializer

  def id
    object.id.to_s
  end

  def status_ids
    object&.status_ids&.map(&:to_s)
  end
end

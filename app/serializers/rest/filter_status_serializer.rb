# frozen_string_literal: true

class REST::FilterStatusSerializer < ActiveModel::Serializer
  attributes :id, :status_id

  def id
    object.id.to_s
  end

  def status_id
    object.status_id.to_s
  end
end

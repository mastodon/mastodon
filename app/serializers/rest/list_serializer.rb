# frozen_string_literal: true

class REST::ListSerializer < ActiveModel::Serializer
  attributes :id, :title, :is_exclusive

  def id
    object.id.to_s
  end
end

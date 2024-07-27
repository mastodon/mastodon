# frozen_string_literal: true

class REST::RoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :permissions, :color, :highlighted

  def id
    object.id.to_s
  end
end

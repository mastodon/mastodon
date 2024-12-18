# frozen_string_literal: true

class REST::CircleSerializer < ActiveModel::Serializer
  attributes :id, :title, :list

  def id
    object.id.to_s
  end

  def list
    return nil unless object.list

    {
      id: object.list.id.to_s,
      title: object.list.title,
    }
  end
end

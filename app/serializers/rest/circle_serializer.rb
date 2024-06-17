# frozen_string_literal: true

class REST::CircleSerializer < ActiveModel::Serializer
  attributes :id, :title, :list

  def id
    object.id.to_s
  end
end

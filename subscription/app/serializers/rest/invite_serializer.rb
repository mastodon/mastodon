# frozen_string_literal: true

class REST::InviteSerializer < ActiveModel::Serializer
  attributes :id, :code, :uses, :max_uses

  def id
    object.id.to_s
  end

  def code
    object.code
  end

  def uses
    object.uses
  end

  def max_uses
    object.max_uses
  end
end

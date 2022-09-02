# frozen_string_literal: true

class REST::GroupMembershipSerializer < ActiveModel::Serializer
  attributes :id, :role
  has_one :account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end

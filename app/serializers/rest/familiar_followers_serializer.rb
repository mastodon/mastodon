# frozen_string_literal: true

class REST::FamiliarFollowersSerializer < ActiveModel::Serializer
  attribute :id

  has_many :accounts, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end

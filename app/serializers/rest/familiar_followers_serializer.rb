# frozen_string_literal: true

class REST::FamiliarFollowersSerializer < REST::BaseSerializer
  attribute :id

  has_many :accounts, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end

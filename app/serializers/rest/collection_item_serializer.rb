# frozen_string_literal: true

class REST::CollectionItemSerializer < ActiveModel::Serializer
  delegate :accepted?, to: :object

  attributes :id, :position, :state

  belongs_to :account, serializer: REST::AccountSerializer, if: :accepted?

  def id
    object.id.to_s
  end
end

# frozen_string_literal: true

class REST::CollectionItemSerializer < ActiveModel::Serializer
  delegate :accepted?, to: :object

  attributes :position, :state

  belongs_to :account, serializer: REST::AccountSerializer, if: :accepted?
end

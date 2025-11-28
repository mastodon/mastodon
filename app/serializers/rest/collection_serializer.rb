# frozen_string_literal: true

class REST::CollectionSerializer < ActiveModel::Serializer
  attributes :uri, :name, :description, :local, :sensitive, :discoverable,
             :created_at, :updated_at

  belongs_to :account, serializer: REST::AccountSerializer
  belongs_to :tag, serializer: REST::StatusSerializer::TagSerializer

  has_many :items, serializer: REST::CollectionItemSerializer

  def items
    object.items_for(current_user&.account)
  end
end

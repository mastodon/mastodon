# frozen_string_literal: true

class REST::CollectionSerializer < ActiveModel::Serializer
  attributes :id, :uri, :name, :description, :language, :account_id,
             :local, :sensitive, :discoverable, :item_count,
             :created_at, :updated_at

  belongs_to :tag, serializer: REST::StatusSerializer::TagSerializer

  has_many :items, serializer: REST::CollectionItemSerializer

  def id
    object.id.to_s
  end

  def items
    object.items_for(current_user&.account)
  end

  def account_id
    object.account_id.to_s
  end
end

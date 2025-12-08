# frozen_string_literal: true

class REST::BaseCollectionSerializer < ActiveModel::Serializer
  attributes :id, :uri, :name, :description, :local, :sensitive,
             :discoverable, :item_count, :created_at, :updated_at

  belongs_to :tag, serializer: REST::StatusSerializer::TagSerializer

  def id
    object.id.to_s
  end

  def item_count
    object.respond_to?(:item_count) ? object.item_count : object.collection_items.count
  end
end

# frozen_string_literal: true

class REST::BaseCollectionSerializer < ActiveModel::Serializer
  attributes :id, :uri, :name, :description, :local, :sensitive,
             :discoverable, :item_count, :created_at, :updated_at

  belongs_to :tag, serializer: REST::StatusSerializer::TagSerializer

  def id
    object.id.to_s
  end
end

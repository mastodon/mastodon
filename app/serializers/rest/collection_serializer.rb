# frozen_string_literal: true

class REST::CollectionSerializer < ActiveModel::Serializer
  attributes :uri, :name, :description, :local, :sensitive, :discoverable,
             :created_at, :updated_at

  belongs_to :account, serializer: REST::AccountSerializer
end

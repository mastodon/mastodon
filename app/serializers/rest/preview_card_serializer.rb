# frozen_string_literal: true

class REST::PreviewCardSerializer < REST::BasePreviewCardSerializer
  class AuthorSerializer < ActiveModel::Serializer
    attributes :name, :url
    has_one :account, serializer: REST::AccountSerializer
  end

  has_many :authors, serializer: AuthorSerializer
end

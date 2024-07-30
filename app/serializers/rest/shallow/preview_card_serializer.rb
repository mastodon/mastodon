# frozen_string_literal: true

class REST::Shallow::PreviewCardSerializer < REST::BasePreviewCardSerializer
  class AuthorSerializer < ActiveModel::Serializer
    attributes :name, :url, :account_id

    def account_id
      object.account_id&.to_s
    end
  end

  has_many :authors, serializer: AuthorSerializer
end

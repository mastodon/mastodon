# frozen_string_literal: true

class REST::CollectionsWithAccountPreviewsSerializer < ActiveModel::Serializer
  has_many :collections, serializer: REST::CollectionSerializer
  has_many :partial_accounts, serializer: REST::PartialAccountSerializer

  def partial_accounts
    object.accounts
  end
end

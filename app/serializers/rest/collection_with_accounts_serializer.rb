# frozen_string_literal: true

class REST::CollectionWithAccountsSerializer < ActiveModel::Serializer
  belongs_to :collection, serializer: REST::CollectionSerializer

  has_many :accounts, serializer: REST::AccountSerializer

  def collection
    object
  end

  def accounts
    [object.account] + object.collection_items.filter_map(&:account)
  end
end

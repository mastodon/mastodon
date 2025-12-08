# frozen_string_literal: true

class REST::CollectionSerializer < REST::BaseCollectionSerializer
  belongs_to :account, serializer: REST::AccountSerializer

  has_many :items, serializer: REST::CollectionItemSerializer

  def items
    object.items_for(current_user&.account)
  end
end

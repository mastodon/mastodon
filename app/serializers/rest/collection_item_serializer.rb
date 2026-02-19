# frozen_string_literal: true

class REST::CollectionItemSerializer < ActiveModel::Serializer
  delegate :accepted?, to: :object

  attributes :id, :state

  attribute :account_id, if: :accepted?

  def id
    object.id.to_s
  end

  def account_id
    object.account_id.to_s
  end
end

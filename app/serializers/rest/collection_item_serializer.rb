# frozen_string_literal: true

class REST::CollectionItemSerializer < ActiveModel::Serializer
  attributes :id, :state, :created_at

  attribute :account_id, if: :accepted_or_pending?

  def id
    object.id.to_s
  end

  def account_id
    object.account_id.to_s
  end

  def accepted_or_pending?
    object.pending? || object.accepted?
  end
end

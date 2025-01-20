# frozen_string_literal: true

class REST::QuoteSerializer < ActiveModel::Serializer
  attributes :state

  has_one :quoted_status, serializer: REST::ShallowStatusSerializer

  def quoted_status
    object.quoted_status if object.accepted?
  end
end

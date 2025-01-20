# frozen_string_literal: true

class REST::BaseQuoteSerializer < ActiveModel::Serializer
  attributes :state

  def quoted_status
    object.quoted_status if object.accepted?
  end
end

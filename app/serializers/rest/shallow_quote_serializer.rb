# frozen_string_literal: true

class REST::ShallowQuoteSerializer < ActiveModel::Serializer
  attributes :state, :quoted_status_id

  def quoted_status_id
    object.quoted_status&.id&.to_s if object.accepted?
  end
end

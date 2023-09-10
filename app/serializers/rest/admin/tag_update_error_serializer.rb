# frozen_string_literal: true

class REST::Admin::TagUpdateErrorSerializer < ActiveModel::Serializer
  attributes :errors

  has_one :tag, serializer: REST::Admin::TagSerializer

  def tag
    object
  end
end

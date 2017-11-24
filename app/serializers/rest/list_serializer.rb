# frozen_string_literal: true

class REST::ListSerializer < ActiveModel::Serializer
  attributes :id, :title
end

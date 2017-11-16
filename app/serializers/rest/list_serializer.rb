# frozen_string_literal: true

class REST::ListSerializer < ActiveModel::Serializer
  attributes :id, :title
  has_many :accounts, serializer: REST::AccountSerializer
end

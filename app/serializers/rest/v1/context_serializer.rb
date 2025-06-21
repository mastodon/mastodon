# frozen_string_literal: true

class REST::V1::ContextSerializer < ActiveModel::Serializer
  has_many :ancestors,   serializer: REST::StatusSerializer
  has_many :descendants, serializer: REST::StatusSerializer
end

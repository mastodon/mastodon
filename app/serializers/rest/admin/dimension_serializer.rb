# frozen_string_literal: true

class REST::Admin::DimensionSerializer < ActiveModel::Serializer
  attributes :key, :data
end

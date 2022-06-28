# frozen_string_literal: true

class REST::FilterResultSerializer < ActiveModel::Serializer
  belongs_to :filter, serializer: REST::FilterSerializer
  has_many :keyword_matches
end

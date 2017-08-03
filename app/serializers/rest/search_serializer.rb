# frozen_string_literal: true

class REST::SearchSerializer < ActiveModel::Serializer
  attributes :hashtags

  has_many :accounts, serializer: REST::AccountSerializer
  has_many :statuses, serializer: REST::StatusSerializer

  def hashtags
    object.hashtags.map(&:name)
  end
end

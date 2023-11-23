# frozen_string_literal: true

class REST::FilterResultSerializer < ActiveModel::Serializer
  belongs_to :filter, serializer: REST::FilterSerializer
  has_many :account_matches
  has_many :keyword_matches
  has_many :status_matches

  def account_matches
    object.account_matches&.map(&:to_s)
  end

  def status_matches
    object.status_matches&.map(&:to_s)
  end
end

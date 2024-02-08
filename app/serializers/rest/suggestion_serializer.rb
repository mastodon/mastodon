# frozen_string_literal: true

class REST::SuggestionSerializer < ActiveModel::Serializer
  attributes :source, :sources

  has_one :account, serializer: REST::AccountSerializer

  LEGACY_SOURCE_TYPE_MAP = {
    featured: 'staff',
    most_followed: 'global',
    most_interactions: 'global',
    # NOTE: Those are not completely accurate, but those are personalized interactions
    similar_to_recently_followed: 'past_interactions',
    friends_of_friends: 'past_interactions',
  }.freeze

  def source
    LEGACY_SOURCE_TYPE_MAP[object.sources.first]
  end
end

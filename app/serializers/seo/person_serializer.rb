# frozen_string_literal: true

class SEO::PersonSerializer < ActiveModel::Serializer
  include FormattingHelper
  include RoutingHelper

  attributes :type, :name, :alternate_name, :identifier, :interaction_statistic,
             :agent_interaction_statistic, :description, :image, :url

  def type
    'Person'
  end

  def name
    object.display_name.presence || object.username
  end

  def alternate_name
    object.local_username_and_domain
  end

  def identifier
    object.local_username_and_domain
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def interaction_statistic
    [
      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/FollowAction',
        user_interaction_count: object.followers_count,
      },
    ]
  end

  def agent_interaction_statistic
    [
      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/WriteAction',
        user_interaction_count: object.statuses_count,
      },
      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/FollowAction',
        user_interaction_count: object.following_count,
      },
    ]
  end

  def description
    object.note
  end

  def image
    full_asset_url(object.avatar.url(:original))
  end
end

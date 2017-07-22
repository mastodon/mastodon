# frozen_string_literal: true

class ActivityPub::AcceptFollowSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::FollowSerializer

  def type
    'Accept'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end
end

# frozen_string_literal: true

class ActivityPub::AcceptFollowSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::FollowSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.target_account), '#accepts/follows/', object.id].join
  end

  def type
    'Accept'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end
end

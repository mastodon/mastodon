# frozen_string_literal: true

class ActivityPub::AcceptJoinSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::JoinSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.group), '#rejects/joins/', object.id].join
  end

  def type
    'Accept'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.group)
  end
end

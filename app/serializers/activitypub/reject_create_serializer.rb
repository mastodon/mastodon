# frozen_string_literal: true

class ActivityPub::RejectCreateSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.actor), '#rejects/creates/', object.id].join
  end

  def type
    'Reject'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.actor)
  end

  def virtual_object
    {
      type: 'Create',
      id: object.create_uri,
      object: object.create_object_uri,
      actor: ActivityPub::TagManager.instance.uri_for(object.create_actor),
    }
  end
end

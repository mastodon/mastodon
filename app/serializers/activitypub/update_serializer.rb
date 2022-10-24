# frozen_string_literal: true

class ActivityPub::UpdateSerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Account'
      ActivityPub::ActorSerializer
    when 'Group'
      ActivityPub::GroupActorSerializer
    else
      super
    end
  end

  attributes :id, :type, :actor, :to

  has_one :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#updates/', object.updated_at.to_i].join
  end

  def type
    'Update'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def to
    [ActivityPub::TagManager::COLLECTIONS[:public]]
  end
end

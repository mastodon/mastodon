# frozen_string_literal: true

class ActivityPub::UpdateSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::ActorSerializer

  def type
    'Update'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object)
  end
end

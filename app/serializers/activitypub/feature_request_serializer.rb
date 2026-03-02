# frozen_string_literal: true

class ActivityPub::FeatureRequestSerializer < ActivityPub::Serializer
  attributes :id, :type, :instrument
  attribute :virtual_object, key: :object

  def id
    object.activity_uri
  end

  def type
    'FeatureRequest'
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def instrument
    ActivityPub::TagManager.instance.uri_for(object.collection)
  end
end

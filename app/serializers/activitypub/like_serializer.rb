# frozen_string_literal: true

class ActivityPub::LikeSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#likes/', object.id].join
  end

  def type
    'Like'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.status)
  end
end

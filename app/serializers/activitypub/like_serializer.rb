# frozen_string_literal: true

class ActivityPub::LikeSerializer < ActiveModel::Serializer
  attributes :type, :actor
  attribute :virtual_object, key: :object

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

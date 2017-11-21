# frozen_string_literal: true

class ActivityPub::FollowSerializer < ActiveModel::Serializer
  attributes :type, :actor
  attribute :id, if: :dereferencable?
  attribute :virtual_object, key: :object

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Follow'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end

  def dereferencable?
    object.respond_to?(:object_type)
  end
end

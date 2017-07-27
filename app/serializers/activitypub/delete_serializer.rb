# frozen_string_literal: true

class ActivityPub::DeleteSerializer < ActiveModel::Serializer
  attributes :type, :actor
  attribute :virtual_object, key: :object

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object)
  end
end

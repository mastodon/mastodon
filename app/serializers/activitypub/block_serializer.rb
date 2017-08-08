# frozen_string_literal: true

class ActivityPub::BlockSerializer < ActiveModel::Serializer
  attributes :type, :actor
  attribute :virtual_object, key: :object

  def type
    'Block'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.target_account)
  end
end

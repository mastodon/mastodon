# frozen_string_literal: true

class ActivityPub::RemoveHashtagSerializer < ActivityPub::Serializer
  attributes :type, :actor, :target
  has_one :object, serializer: ActivityPub::HashtagSerializer

  def type
    'Remove'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def target
    ActivityPub::TagManager.instance.collection_uri_for(object.account, :featured)
  end
end

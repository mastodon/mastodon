# frozen_string_literal: true

class ActivityPub::AddNoteSerializer < ActivityPub::Serializer
  attributes :type, :actor, :target

  has_one :proper_object, key: :object

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def target
    ActivityPub::TagManager.instance.collection_uri_for(object.account, :featured)
  end
end

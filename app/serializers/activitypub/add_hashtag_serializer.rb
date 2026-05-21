# frozen_string_literal: true

class ActivityPub::AddHashtagSerializer < ActivityPub::Serializer
  attributes :type, :actor, :target

  has_one :object, serializer: ActivityPub::HashtagSerializer

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def target
    # Technically this is not correct, as tags have their own collection.
    # But sadly we do not store the collection URI for tags anywhere so cannot
    # handle `Add` activities to that properly (yet). The receiving code for
    # this currently looks at the type of the contained objects to do the
    # right thing.
    ActivityPub::TagManager.instance.collection_uri_for(object.account, :featured)
  end
end

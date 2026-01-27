# frozen_string_literal: true

class ActivityPub::AddSerializer < ActivityPub::Serializer
  class UriSerializer < ActiveModel::Serializer
    include RoutingHelper

    def serializable_hash(*_args)
      ActivityPub::TagManager.instance.uri_for(object)
    end
  end

  def self.serializer_for(model, options)
    case model
    when Status
      UriSerializer
    when FeaturedTag
      ActivityPub::HashtagSerializer
    when Collection
      ActivityPub::FeaturedCollectionSerializer
    else
      super
    end
  end

  include RoutingHelper

  attributes :type, :actor, :target
  has_one :proper_object, key: :object

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    object
  end

  def target
    case object
    when Status, FeaturedTag
      # Technically this is not correct, as tags have their own collection.
      # But sadly we do not store the collection URI for tags anywhere so cannot
      # handle `Add` activities to that properly (yet). The receiving code for
      # this currently looks at the type of the contained objects to do the
      # right thing.
      ActivityPub::TagManager.instance.collection_uri_for(object.account, :featured)
    when Collection
      ap_account_featured_collections_url(object.account_id)
    end
  end
end

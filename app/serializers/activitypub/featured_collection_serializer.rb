# frozen_string_literal: true

class ActivityPub::FeaturedCollectionSerializer < ActivityPub::Serializer
  class FeaturedItemSerializer < ActivityPub::Serializer
    attributes :type, :featured_object, :featured_object_type

    def type
      'FeaturedItem'
    end

    def featured_object
      ActivityPub::TagManager.instance.uri_for(object.account)
    end

    def featured_object_type
      object.account.actor_type || 'Person'
    end
  end

  attributes :id, :type, :total_items, :name, :attributed_to,
             :sensitive, :discoverable, :published, :updated

  attribute :summary, unless: :language_present?
  attribute :summary_map, if: :language_present?

  has_one :tag, key: :topic, serializer: ActivityPub::NoteSerializer::TagSerializer

  has_many :collection_items, key: :ordered_items, serializer: FeaturedItemSerializer

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'FeaturedCollection'
  end

  def summary
    object.description
  end

  def summary_map
    { object.language => object.description }
  end

  def attributed_to
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def total_items
    object.collection_items.size
  end

  def published
    object.created_at.iso8601
  end

  def updated
    object.updated_at.iso8601
  end

  def language_present?
    object.language.present?
  end
end

# frozen_string_literal: true

class ActivityPub::FeaturedCollectionSerializer < ActivityPub::Serializer
  attributes :id, :type, :total_items, :name, :attributed_to,
             :sensitive, :discoverable, :published, :updated

  attribute :summary, unless: :language_present?
  attribute :summary_map, if: :language_present?

  has_one :tag, key: :topic, serializer: ActivityPub::NoteSerializer::TagSerializer

  has_many :collection_items, key: :ordered_items, serializer: ActivityPub::FeaturedItemSerializer

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

# frozen_string_literal: true

class ActivityPub::CollectionSerializer < ActivityPub::Serializer
  class StringSerializer < ActiveModel::Serializer
    # Despite the name, it does not return a hash, but the same can be said of
    # the ActiveModel::Serializer::CollectionSerializer class which handles
    # arrays.
    def serializable_hash(*_args)
      object
    end
  end

  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      ActivityPub::NoteSerializer
    when 'FeaturedTag'
      ActivityPub::HashtagSerializer
    when 'ActivityPub::CollectionPresenter'
      ActivityPub::CollectionSerializer
    when 'String'
      StringSerializer
    else
      super
    end
  end

  attribute :id, if: -> { object.id.present? }
  attribute :type
  attribute :total_items, if: -> { object.size.present? }
  attribute :next, if: -> { object.next.present? }
  attribute :prev, if: -> { object.prev.present? }
  attribute :part_of, if: -> { object.part_of.present? }

  has_one :first, if: -> { object.first.present? }
  has_one :last, if: -> { object.last.present? }
  has_many :items, key: :items, if: -> { (!object.items.nil? || page?) && !ordered? }
  has_many :items, key: :ordered_items, if: -> { (!object.items.nil? || page?) && ordered? }

  def type
    if page?
      ordered? ? 'OrderedCollectionPage' : 'CollectionPage'
    else
      ordered? ? 'OrderedCollection' : 'Collection'
    end
  end

  def total_items
    object.size
  end

  private

  def ordered?
    object.type == :ordered
  end

  def page?
    object.part_of.present? || object.page.present?
  end
end

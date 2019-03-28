# frozen_string_literal: true

class ActivityPub::CollectionSerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    return ActivityPub::NoteSerializer if model.class.name == 'Status'
    return ActivityPub::CollectionSerializer if model.class.name == 'ActivityPub::CollectionPresenter'
    super
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

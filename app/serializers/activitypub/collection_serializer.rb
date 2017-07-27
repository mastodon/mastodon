# frozen_string_literal: true

class ActivityPub::CollectionSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    return ActivityPub::ActivitySerializer if model.class.name == 'Status'
    super
  end

  attributes :id, :type, :total_items

  has_many :items, key: :ordered_items

  def type
    case object.type
    when :ordered
      'OrderedCollection'
    else
      'Collection'
    end
  end

  def total_items
    object.size
  end
end

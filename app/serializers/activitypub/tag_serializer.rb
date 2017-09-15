# frozen_string_literal: true

class ActivityPub::TagTimelineSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    return ActivityPub::ActivitySerializer if model.class.name == 'Status'
    super
  end

  attributes :id, :type, :total_items

  has_many :ordered_items

  def id
    tag_url object.tag
  end

  def type
    'OrderedCollection'
  end

  def total_items
    statuses.count
  end

  def ordered_items
    statuses = statuses.merge(object.scope)
    statuses = cache_collection(statuses, Status)
    statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
  end

  private

  def statuses
    Status.as_tag_timeline(object.tag, object.account, object.local_only)
  end
end

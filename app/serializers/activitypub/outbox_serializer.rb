# frozen_string_literal: true

class ActivityPub::OutboxSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    return ActivityPub::ActivitySerializer if model.class.name == 'Status'
    super
  end

  def id
    account_outbox_url object.account
  end

  def type
    'OrderedCollection'
  end

  def total_items
    object.account.statuses_count
  end

  def items
    statuses = object.account.statuses.merge(object.scope)
    cache_collection statuses, Status
  end
end

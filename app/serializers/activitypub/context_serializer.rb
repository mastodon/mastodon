# frozen_string_literal: true

class ActivityPub::ContextSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :first

  has_one :first, serializer: ActivityPub::CollectionSerializer

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Collection'
  end

  def first
    conversation_statuses = object.statuses[0..5]
    last_status = conversation_statuses.last
    conversation_statuses = conversation_statuses.pluck(:id, :uri)
    last_id = conversation_statuses.last&.first
    has_more = object.statuses.count > ActivityPub::ContextsController::DESCENDANTS_LIMIT

    next_page = if has_more
                  last_id ? ActivityPub::TagManager.instance.context_uri_for(last_status, page: true, min_id: last_id) : ActivityPub::TagManager.instance.context_uri_for(last_status, page: true, only_other_accounts: true)
                end

    ActivityPub::CollectionPresenter.new(
      type: :unordered,
      part_of: ActivityPub::TagManager.instance.uri_for(object),
      items: conversation_statuses.map(&:second),
      next: next_page
    )
  end
end

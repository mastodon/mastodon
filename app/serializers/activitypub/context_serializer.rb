# frozen_string_literal: true

class ActivityPub::ContextSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :attributed_to

  has_one :first, serializer: ActivityPub::CollectionSerializer

  def type
    'Collection'
  end
end

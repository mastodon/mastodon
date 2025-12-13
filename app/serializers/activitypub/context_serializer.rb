# frozen_string_literal: true

class ActivityPub::ContextSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :attributed_to, :first

  def type
    'Collection'
  end
end

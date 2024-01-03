# frozen_string_literal: true

class NodeInfo::DiscoverySerializer < ActiveModel::Serializer
  include RoutingHelper

  attribute :links

  def links
    [
      { rel: 'http://nodeinfo.diaspora.software/ns/schema/2.0', href: nodeinfo_schema_url },
      { rel: 'https://www.w3.org/ns/activitystreams#Application', href: instance_actor_url },
    ]
  end
end

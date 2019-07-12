# frozen_string_literal: true

class NodeDiscoverySerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :links

  def links
    [
      {
        rel: 'http://nodeinfo.diaspora.software/ns/schema/2.0',
        href: node_info_schema_url('2.0'),
      },
      {
        rel: 'http://nodeinfo.diaspora.software/ns/schema/2.1',
        href: node_info_schema_url('2.1'),
      },
    ]
  end
end

# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def index
      discovery = {
        links: [
          {
            rel: 'http://nodeinfo.diaspora.software/ns/schema/2.1',
            href: node_info_21_url,
          }
        ]
      }
      render json: discovery
    end

    def show
      node_info = NodeInfoSerializer.new.node_info
      render json: node_info.as_json
    end
  end
end

# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def index
      discovery = {
        links: [
          {
            rel: 'http://nodeinfo.diaspora.software/ns/schema/2.0',
            href: node_info_schema_url('2.0'),
          },
          {
            rel: 'http://nodeinfo.diaspora.software/ns/schema/2.1',
            href: node_info_schema_url('2.1'),
          }
        ]
      }
      render json: discovery
    end

    def show
      node_info = Rails.cache.fetch('nodeinfo', expires_in: 10.minutes) { NodeInfoSerializer.new.node_info }

      if params[:format] == '0'
        node_info[:software].delete(:repository)
        render json: node_info.as_json
      else
        render json: node_info.as_json
      end
    end
  end
end

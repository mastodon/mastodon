# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    protect_from_forgery with: :exception

    include CacheConcern

    before_action { response.headers['Vary'] = 'Accept' }

    def index
      expires_in 3.days, public: true
      render_with_cache json: {}, serializer: NodeInfo::DiscoverySerializer, adapter: NodeInfo::Adapter, expires_in: 3.days, root: 'nodeinfo'
    end

    def show
      expires_in 30.minutes, public: true
      render_with_cache json: {}, serializer: NodeInfo::Serializer, adapter: NodeInfo::Adapter, expires_in: 30.minutes, root: 'nodeinfo'
    end
  end
end

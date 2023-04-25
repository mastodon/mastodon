# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include CacheConcern

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

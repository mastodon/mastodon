# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    include CacheConcern

    before_action { response.headers['Vary'] = 'Accept' }

    def index
      expires_in 3.days, public: true
      render json: {}, serializer: NodeInfo::DiscoverySerializer, adapter: NodeInfo::Adapter, root: 'nodeinfo'
    end

    def show
      expires_in 30.minutes, public: true
      render json: {}, serializer: NodeInfo::Serializer, adapter: NodeInfo::Adapter, root: 'nodeinfo'
    end
  end
end

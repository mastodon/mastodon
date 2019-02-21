# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def index
      render json: ActiveModelSerializers::SerializableResource.new({}, serializer: NodeDiscoverySerializer)
    end

    def show
      render json: ActiveModelSerializers::SerializableResource.new({}, serializer: NodeInfoSerializer)
    end
  end
end

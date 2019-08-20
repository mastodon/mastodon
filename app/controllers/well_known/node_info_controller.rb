# frozen_string_literal: true

module WellKnown
  class NodeInfoController < ActionController::Base
    include RoutingHelper

    def index
      expires_in 3.days, public: true
      render json: ActiveModelSerializers::SerializableResource.new({}, serializer: NodeDiscoverySerializer), root: 'nodeinfo'
    end

    def show
      expires_in 30.minutes, public: true
      render json: ActiveModelSerializers::SerializableResource.new({}, serializer: NodeInfoSerializer, version: "2.#{params[:format]}"), root: 'nodeinfo'
    end
  end
end

# frozen_string_literal: true

module WellKnown
  class NodeInfoController < BaseController
    include CacheConcern

    # Prevent `active_model_serializer`'s `ActionController::Serialization` from calling `current_user`
    # and thus re-issuing session cookies
    serialization_scope nil

    def index
      expires_in LONG_DURATION, public: true
      render_with_cache json: {}, serializer: NodeInfo::DiscoverySerializer, adapter: NodeInfo::Adapter, expires_in: LONG_DURATION, root: 'nodeinfo'
    end

    def show
      expires_in NEAR_DURATION, public: true
      render_with_cache json: {}, serializer: NodeInfo::Serializer, adapter: NodeInfo::Adapter, expires_in: NEAR_DURATION, root: 'nodeinfo'
    end
  end
end

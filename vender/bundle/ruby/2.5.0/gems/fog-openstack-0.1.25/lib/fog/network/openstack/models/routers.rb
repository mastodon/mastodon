require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/router'

module Fog
  module Network
    class OpenStack
      class Routers < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::Router

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_routers(filters), 'routers')
        end

        def get(router_id)
          if router = service.get_router(router_id).body['router']
            new(router)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

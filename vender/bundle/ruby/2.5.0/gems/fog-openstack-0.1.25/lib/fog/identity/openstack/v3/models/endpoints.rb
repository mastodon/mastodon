require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/service'

module Fog
  module Identity
    class OpenStack
      class V3
        class Endpoints < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Endpoint

          def all(options = {})
            load_response(service.list_endpoints(options), 'endpoints')
          end

          def find_by_id(id)
            cached_endpoint = find { |endpoint| endpoint.id == id }
            return cached_endpoint if cached_endpoint
            endpoint_hash = service.get_endpoint(id).body['endpoint']
            Fog::Identity::OpenStack::V3::Endpoint.new(
              endpoint_hash.merge(:service => service)
            )
          end
        end
      end
    end
  end
end

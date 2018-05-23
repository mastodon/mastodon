require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/service'

module Fog
  module Identity
    class OpenStack
      class V3
        class Services < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Service

          def all(options = {})
            load_response(service.list_services(options), 'services')
          end

          def find_by_id(id)
            cached_service = find { |service| service.id == id }
            return cached_service if cached_service
            service_hash = service.get_service(id).body['service']
            Fog::Identity::OpenStack::V3::Service.new(
              service_hash.merge(:service => service)
            )
          end

          def destroy(id)
            service = find_by_id(id)
            service.destroy
          end
        end
      end
    end
  end
end

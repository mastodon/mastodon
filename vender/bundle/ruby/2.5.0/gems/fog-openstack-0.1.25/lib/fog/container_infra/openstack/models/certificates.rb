require 'fog/openstack/models/collection'
require 'fog/container_infra/openstack/models/certificate'

module Fog
  module ContainerInfra
    class OpenStack
      class Certificates < Fog::OpenStack::Collection

        model Fog::ContainerInfra::OpenStack::Certificate

        def create(bay_uuid)
          resource = service.create_certificate(bay_uuid).body
          new(resource)
        end

        def get(bay_uuid)
          resource = service.get_certificate(bay_uuid).body
          new(resource)
        rescue Fog::ContainerInfra::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

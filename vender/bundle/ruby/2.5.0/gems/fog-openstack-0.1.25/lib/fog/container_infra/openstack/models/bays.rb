require 'fog/openstack/models/collection'
require 'fog/container_infra/openstack/models/bay'

module Fog
  module ContainerInfra
    class OpenStack
      class Bays < Fog::OpenStack::Collection
        model Fog::ContainerInfra::OpenStack::Bay

        def all
          load_response(service.list_bays, "bays")
        end

        def get(bay_uuid_or_name)
          resource = service.get_bay(bay_uuid_or_name).body
          new(resource)
        rescue Fog::ContainerInfra::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

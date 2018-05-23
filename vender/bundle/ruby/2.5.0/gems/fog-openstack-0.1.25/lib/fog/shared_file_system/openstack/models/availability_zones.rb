require 'fog/openstack/models/collection'
require 'fog/shared_file_system/openstack/models/availability_zone'

module Fog
  module SharedFileSystem
    class OpenStack
      class AvailabilityZones < Fog::OpenStack::Collection
        model Fog::SharedFileSystem::OpenStack::AvailabilityZone

        def all
          load_response(service.list_availability_zones(), 'availability_zones')
        end
      end
    end
  end
end

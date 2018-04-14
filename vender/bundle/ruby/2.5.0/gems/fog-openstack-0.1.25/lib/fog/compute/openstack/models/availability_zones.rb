require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/availability_zone'

module Fog
  module Compute
    class OpenStack
      class AvailabilityZones < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::AvailabilityZone

        def all(options = {})
          data = service.list_zones_detailed(options)
          load_response(data, 'availabilityZoneInfo')
        end

        def summary(options = {})
          data = service.list_zones(options)
          load_response(data, 'availabilityZoneInfo')
        end
      end
    end
  end
end

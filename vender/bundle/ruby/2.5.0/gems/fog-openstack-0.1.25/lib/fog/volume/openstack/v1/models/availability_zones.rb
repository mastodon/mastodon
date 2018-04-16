require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/availability_zone'
require 'fog/volume/openstack/models/availability_zones'

module Fog
  module Volume
    class OpenStack
      class V1
        class AvailabilityZones < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::AvailabilityZone
          include Fog::Volume::OpenStack::AvailabilityZones
        end
      end
    end
  end
end

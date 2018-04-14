require 'fog/volume/openstack/models/availability_zone'

module Fog
  module Volume
    class OpenStack
      class V2
        class AvailabilityZone < Fog::Volume::OpenStack::AvailabilityZone
          identity :zoneName

          attribute :zoneState
        end
      end
    end
  end
end

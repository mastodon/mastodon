require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class AvailabilityZone < Fog::OpenStack::Model
        identity :zoneName

        attribute :hosts
        attribute :zoneLabel
        attribute :zoneState

        def to_s
          zoneName
        end
      end
    end
  end
end

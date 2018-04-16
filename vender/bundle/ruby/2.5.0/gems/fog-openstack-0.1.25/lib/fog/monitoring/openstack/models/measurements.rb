require 'fog/openstack/models/collection'
require 'fog/monitoring/openstack/models/measurement'

module Fog
  module Monitoring
    class OpenStack
      class Measurements < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::Measurement

        def find(options = {})
          load_response(service.find_measurements(options), 'elements')
        end
      end
    end
  end
end

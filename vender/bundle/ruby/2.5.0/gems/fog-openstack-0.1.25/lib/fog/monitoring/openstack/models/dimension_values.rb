require 'fog/openstack/models/collection'
require 'fog/monitoring/openstack/models/dimension_value'

module Fog
  module Monitoring
    class OpenStack
      class DimensionValues < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::DimensionValue

        def all(dimension_name, options = {})
          load_response(service.list_dimension_values(dimension_name, options), 'elements')
        end
      end
    end
  end
end

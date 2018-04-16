require 'fog/openstack/models/collection'
require 'fog/monitoring/openstack/models/statistic'

module Fog
  module Monitoring
    class OpenStack
      class Statistics < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::Statistic

        def all(options = {})
          load_response(service.list_statistics(options), 'elements')
        end
      end
    end
  end
end

require 'fog/openstack/models/collection'
require 'fog/monitoring/openstack/models/alarm_count'

module Fog
  module Monitoring
    class OpenStack
      class AlarmCounts < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::AlarmCount

        def get(options = {})
          load_response(service.get_alarm_counts(options))
        end
      end
    end
  end
end

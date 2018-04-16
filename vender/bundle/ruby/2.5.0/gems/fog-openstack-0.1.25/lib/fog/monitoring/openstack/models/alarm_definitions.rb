require 'fog/openstack/models/collection'
require 'fog/monitoring/openstack/models/alarm_definition'

module Fog
  module Monitoring
    class OpenStack
      class AlarmDefinitions < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::AlarmDefinition

        def create(attributes)
          super(attributes)
        end

        def update(attributes)
          super(attributes)
        end

        def patch(attributes)
          super(attributes)
        end

        def all(options = {})
          load_response(service.list_alarm_definitions(options), 'elements')
        end

        def find_by_id(id)
          cached_alarm_definition = detect { |alarm_definition| alarm_definition.id == id }
          return cached_alarm_definition if cached_alarm_definition
          alarm_definition_hash = service.get_alarm_definition(id).body
          Fog::Monitoring::OpenStack::AlarmDefinition.new(
            alarm_definition_hash.merge(:service => service)
          )
        end

        def destroy(id)
          alarm_definition = find_by_id(id)
          alarm_definition.destroy
        end
      end
    end
  end
end

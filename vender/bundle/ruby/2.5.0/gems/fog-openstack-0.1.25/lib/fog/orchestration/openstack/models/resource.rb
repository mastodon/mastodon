require 'fog/openstack/models/model'

module Fog
  module Orchestration
    class OpenStack
      class Resource < Fog::OpenStack::Model
        include Reflectable

        identity :id

        %w(resource_name description links logical_resource_id physical_resource_id resource_status
           updated_time required_by resource_status_reason resource_type).each do |a|
          attribute a.to_sym
        end

        def events(options = {})
          @events ||= service.events.all(self, options)
        end

        def metadata
          @metadata ||= service.show_resource_metadata(stack, resource_name).body['metadata']
        end

        def template
          @template ||= service.templates.get(self)
        end
      end
    end
  end
end

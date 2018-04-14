require 'fog/openstack/models/collection'
require 'fog/orchestration/openstack/models/resource'

module Fog
  module Orchestration
    class OpenStack
      class Resources < Fog::OpenStack::Collection
        model Fog::Orchestration::OpenStack::Resource

        def types
          service.list_resource_types.body['resource_types'].sort
        end

        def all(options = {}, deprecated_options = {})
          data = service.list_resources(options, deprecated_options)
          load_response(data, 'resources')
        end

        def get(resource_name, stack = nil)
          stack = first.stack if stack.nil?
          data  = service.show_resource_data(stack.stack_name, stack.id, resource_name).body['resource']
          new(data)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

        def metadata(stack_name, stack_id, resource_name)
          service.show_resource_metadata(stack_name, stack_id, resource_name).body['resource']
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

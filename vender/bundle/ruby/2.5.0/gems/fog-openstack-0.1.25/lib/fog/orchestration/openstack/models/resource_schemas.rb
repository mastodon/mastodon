require 'fog/openstack/models/collection'

module Fog
  module Orchestration
    class OpenStack
      class ResourceSchemas < Fog::OpenStack::Collection
        def get(resource_type)
          service.show_resource_schema(resource_type).body
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

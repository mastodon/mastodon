require 'fog/openstack/models/collection'
require 'fog/metric/openstack/models/resource'

module Fog
  module Metric
    class OpenStack
      class Resources < Fog::OpenStack::Collection

        model Fog::Metric::OpenStack::Resource

        def all(options = {})
          load_response(service.list_resources(options))
        end

        def find_by_id(resource_id)
          resource = service.get_resource(resource_id).body
          new(resource)
        rescue Fog::Metric::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

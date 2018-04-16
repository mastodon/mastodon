require 'fog/openstack/models/collection'
require 'fog/metering/openstack/models/resource'

module Fog
  module Metering
    class OpenStack
      class Resources < Fog::OpenStack::Collection
        model Fog::Metering::OpenStack::Resource

        def all(_detailed = true)
          load_response(service.list_resources)
        end

        def find_by_id(resource_id)
          resource = service.get_resource(resource_id).body
          new(resource)
        rescue Fog::Metering::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

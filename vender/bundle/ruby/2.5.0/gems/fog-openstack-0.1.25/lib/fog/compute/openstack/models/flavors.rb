require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/flavor'

module Fog
  module Compute
    class OpenStack
      class Flavors < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::Flavor

        def all(options = {})
          data = service.list_flavors_detail(options)
          load_response(data, 'flavors')
        end

        def summary(options = {})
          data = service.list_flavors(options)
          load_response(data, 'flavors')
        end

        def get(flavor_id)
          data = service.get_flavor_details(flavor_id).body['flavor']
          new(data)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

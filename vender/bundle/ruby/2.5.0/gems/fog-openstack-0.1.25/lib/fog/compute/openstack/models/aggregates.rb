require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/aggregate'

module Fog
  module Compute
    class OpenStack
      class Aggregates < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::Aggregate

        def all(options = {})
          load_response(service.list_aggregates(options), 'aggregates')
        end

        def find_by_id(id)
          new(service.get_aggregate(id).body['aggregate'])
        end
        alias get find_by_id

        def destroy(id)
          aggregate = find_by_id(id)
          aggregate.destroy
        end
      end
    end
  end
end

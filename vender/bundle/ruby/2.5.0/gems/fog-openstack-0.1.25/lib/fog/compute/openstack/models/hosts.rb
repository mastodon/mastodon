require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/host'

module Fog
  module Compute
    class OpenStack
      class Hosts < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::Host

        def all(options = {})
          data = service.list_hosts(options)
          load_response(data, 'hosts')
        end

        def get(host_name)
          if host = service.get_host_details(host_name).body['host']
            new('host_name' => host_name,
                'details'   => host)
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

require 'fog/openstack/models/collection'
require 'fog/nfv/openstack/models/vnf'

module Fog
  module NFV
    class OpenStack
      class Vnfs < Fog::OpenStack::Collection
        model Fog::NFV::OpenStack::Vnf

        def all(options = {})
          load_response(service.list_vnfs(options), 'vnfs')
        end

        def get(uuid)
          data = service.get_vnf(uuid).body['vnf']
          new(data)
        rescue Fog::NFV::OpenStack::NotFound
          nil
        end

        def destroy(uuid)
          vnf = get(uuid)
          vnf.destroy
        end
      end
    end
  end
end

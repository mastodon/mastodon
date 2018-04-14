require 'fog/openstack/models/collection'
require 'fog/nfv/openstack/models/vnfd'

module Fog
  module NFV
    class OpenStack
      class Vnfds < Fog::OpenStack::Collection
        model Fog::NFV::OpenStack::Vnfd

        def all(options = {})
          load_response(service.list_vnfds(options), 'vnfds')
        end

        def get(uuid)
          data = service.get_vnfd(uuid).body['vnfd']
          new(data)
        rescue Fog::NFV::OpenStack::NotFound
          nil
        end

        def destroy(uuid)
          vnfd = get(uuid)
          vnfd.destroy
        end
      end
    end
  end
end

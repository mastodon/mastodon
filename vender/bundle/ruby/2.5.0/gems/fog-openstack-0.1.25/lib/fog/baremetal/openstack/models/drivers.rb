require 'fog/openstack/models/collection'
require 'fog/baremetal/openstack/models/driver'

module Fog
  module Baremetal
    class OpenStack
      class Drivers < Fog::OpenStack::Collection
        model Fog::Baremetal::OpenStack::Driver

        def all(options = {})
          load_response(service.list_drivers(options), 'drivers')
        end

        def find_by_name(name)
          new(service.get_driver(name).body)
        end
        alias get find_by_name
      end
    end
  end
end

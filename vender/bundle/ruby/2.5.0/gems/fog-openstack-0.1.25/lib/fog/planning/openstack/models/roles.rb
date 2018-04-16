require 'fog/openstack/models/collection'
require 'fog/planning/openstack/models/role'

module Fog
  module Openstack
    class Planning
      class Roles < Fog::OpenStack::Collection
        model Fog::Openstack::Planning::Role

        def all(options = {})
          load_response(service.list_roles(options))
        end
      end
    end
  end
end

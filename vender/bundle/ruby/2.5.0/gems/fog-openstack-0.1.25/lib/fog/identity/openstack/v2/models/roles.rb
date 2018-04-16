require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v2/models/role'

module Fog
  module Identity
    class OpenStack
      class V2
        class Roles < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V2::Role

          def all(options = {})
            load_response(service.list_roles(options), 'roles')
          end

          def get(id)
            service.get_role(id)
          end
        end
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog

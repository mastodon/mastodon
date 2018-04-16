require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/role'

module Fog
  module Identity
    class OpenStack
      class V3
        class Roles < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Role

          def all(options = {})
            load_response(service.list_roles(options), 'roles')
          end

          def assignments(options = {})
            # TODO(lsmola) this method doesn't make much sense, it should be moved to role.rb and automatically add
            # role.id filter. Otherwise it's just duplication.
            Fog::Logger.deprecation("Calling OpenStack[:keystone].roles.assignments(options) method which"\
                                    " deprecated, call OpenStack[:keystone].role_assignments.all(options) instead")
            load(service.list_role_assignments(options).body['role_assignments'])
          end

          def find_by_id(id)
            cached_role = find { |role| role.id == id }
            return cached_role if cached_role
            role_hash = service.get_role(id).body['role']
            Fog::Identity::OpenStack::V3.role.new(
              role_hash.merge(:service => service)
            )
          end

          def destroy(id)
            role = find_by_id(id)
            role.destroy
          end
        end
      end
    end
  end
end

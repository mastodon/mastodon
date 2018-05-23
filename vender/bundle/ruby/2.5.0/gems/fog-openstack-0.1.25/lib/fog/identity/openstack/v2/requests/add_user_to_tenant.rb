module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def add_user_to_tenant(tenant_id, user_id, role_id)
            request(
              :expects => 200,
              :method  => 'PUT',
              :path    => "/tenants/#{tenant_id}/users/#{user_id}/roles/OS-KSADM/#{role_id}"
            )
          end
        end # class Real

        class Mock
          def add_user_to_tenant(tenant_id, user_id, role_id)
            role = data[:roles][role_id]
            data[:user_tenant_membership][tenant_id] ||= {}
            data[:user_tenant_membership][tenant_id][user_id] ||= []
            data[:user_tenant_membership][tenant_id][user_id].push(role['id']).uniq!

            response = Excon::Response.new
            response.status = 200
            response.body = {
              'role' => {
                'id'   => role['id'],
                'name' => role['name']
              }
            }
            response
          end # def add_user_to_tenant
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end

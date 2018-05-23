module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def list_roles_for_user_on_tenant(tenant_id, user_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "tenants/#{tenant_id}/users/#{user_id}/roles"
            )
          end # def list_roles_for_user_on_tenant
        end # class Real

        class Mock
          def list_roles_for_user_on_tenant(tenant_id, user_id)
            data[:user_tenant_membership][tenant_id] ||= {}
            data[:user_tenant_membership][tenant_id][user_id] ||= []
            roles = data[:user_tenant_membership][tenant_id][user_id].map do |role_id|
              data[:roles][role_id]
            end

            Excon::Response.new(
              :body   => {'roles' => roles},
              :status => 200
            )
          end # def list_roles_for_user_on_tenant
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog

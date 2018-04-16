module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def delete_user_role(tenant_id, user_id, role_id)
            request(
              :expects => 204,
              :method  => 'DELETE',
              :path    => "/tenants/#{tenant_id}/users/#{user_id}/roles/OS-KSADM/#{role_id}"
            )
          end
        end

        class Mock
          def delete_user_role(_tenant_id, _user_id, _role_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end # class V2
    end
  end
end

module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def create_user_role(tenant_id, user_id, role_id)
            request(
              :expects => 200,
              :method  => 'PUT',
              :path    => "/tenants/#{tenant_id}/users/#{user_id}/roles/OS-KSADM/#{role_id}"
            )
          end
        end

        class Mock
          def create_user_role(_tenant_id, _user_id, role_id)
            Excon::Response.new(
              :body   => {'role' => data[:roles][role_id]},
              :status => 200
            )
          end
        end
      end # class V2
    end
  end
end

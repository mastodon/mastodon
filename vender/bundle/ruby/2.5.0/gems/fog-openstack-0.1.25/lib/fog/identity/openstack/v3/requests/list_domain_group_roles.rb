module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_domain_group_roles(id, group_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "domains/#{id}/groups/#{group_id}/roles"
            )
          end
        end

        class Mock
          def list_domain_user_roles(id, group_id)
          end
        end
      end
    end
  end
end

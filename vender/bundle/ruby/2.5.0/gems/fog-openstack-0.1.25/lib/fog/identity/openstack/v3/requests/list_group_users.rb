module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_group_users(id, options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "groups/#{id}/users",
              :query   => options
            )
          end
        end

        class Mock
          def list_group_users
          end
        end
      end
    end
  end
end

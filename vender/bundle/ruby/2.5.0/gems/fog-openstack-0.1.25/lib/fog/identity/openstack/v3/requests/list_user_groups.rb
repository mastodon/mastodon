module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_user_groups(user_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "users/#{user_id}/groups"
            )
          end
        end

        class Mock
          def list_user_groups
          end
        end
      end
    end
  end
end

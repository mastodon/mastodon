module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def add_user_to_group(group_id, user_id)
            request(
              :expects => [204],
              :method  => 'PUT',
              :path    => "groups/#{group_id}/users/#{user_id}"
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

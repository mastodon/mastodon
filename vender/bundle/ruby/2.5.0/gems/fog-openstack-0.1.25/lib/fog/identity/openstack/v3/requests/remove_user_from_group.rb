module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def remove_user_from_group(group_id, user_id)
            request(
              :expects => [204],
              :method  => 'DELETE',
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

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_user(id, user)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "users/#{id}",
              :body    => Fog::JSON.encode(:user => user)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

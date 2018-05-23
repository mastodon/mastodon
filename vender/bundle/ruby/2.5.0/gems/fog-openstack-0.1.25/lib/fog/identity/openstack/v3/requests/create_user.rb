module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def create_user(user)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "users",
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

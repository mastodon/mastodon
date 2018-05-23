module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_users(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "users",
              :query   => options
            )
          end
        end

        class Mock
          def list_users(options = {})
          end
        end
      end
    end
  end
end

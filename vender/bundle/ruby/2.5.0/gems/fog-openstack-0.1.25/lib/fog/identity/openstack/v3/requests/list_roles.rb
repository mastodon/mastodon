module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_roles(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "roles",
              :query   => options
            )
          end
        end

        class Mock
          def list_roles(options = {})
          end
        end
      end
    end
  end
end

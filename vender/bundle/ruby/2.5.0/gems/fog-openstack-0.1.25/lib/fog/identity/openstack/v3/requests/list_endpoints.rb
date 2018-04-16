module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_endpoints(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "endpoints",
              :query   => options
            )
          end
        end

        class Mock
          def list_endpoints(options = {})
          end
        end
      end
    end
  end
end

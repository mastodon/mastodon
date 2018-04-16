module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_services(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "services",
              :query   => options
            )
          end
        end

        class Mock
          def list_services(options = {})
          end
        end
      end
    end
  end
end

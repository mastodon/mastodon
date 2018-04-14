module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def list_os_credentials(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "credentials",
              :query   => options
            )
          end
        end

        class Mock
          def list_os_credentials(options = {})
          end
        end
      end
    end
  end
end

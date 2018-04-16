module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def auth_domains(options = {})
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "auth/domains",
              :query   => options
            )
          end
        end

        class Mock
          def auth_domains
          end
        end
      end
    end
  end
end

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def create_service(service)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "services",
              :body    => Fog::JSON.encode(:service => service)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def create_endpoint(endpoint)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "endpoints",
              :body    => Fog::JSON.encode(:endpoint => endpoint)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

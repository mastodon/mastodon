module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_endpoint(id, endpoint)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "endpoints/#{id}",
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

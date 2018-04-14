module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_service(id, service)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "services/#{id}",
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

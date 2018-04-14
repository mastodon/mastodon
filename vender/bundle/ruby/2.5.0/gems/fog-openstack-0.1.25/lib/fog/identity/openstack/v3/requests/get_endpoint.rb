module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_endpoint(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "endpoints/#{id}"
            )
          end
        end

        class Mock
          def get_endpoint(id)
          end
        end
      end
    end
  end
end

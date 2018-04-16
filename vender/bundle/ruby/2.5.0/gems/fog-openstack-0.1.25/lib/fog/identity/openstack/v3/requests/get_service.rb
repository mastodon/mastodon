module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_service(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "projects/#{id}"
            )
          end
        end

        class Mock
          def get_service(id)
          end
        end
      end
    end
  end
end

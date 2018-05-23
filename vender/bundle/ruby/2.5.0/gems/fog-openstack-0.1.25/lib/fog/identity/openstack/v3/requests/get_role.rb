module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_role(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "roles/#{id}"
            )
          end
        end

        class Mock
          def get_role(id)
          end
        end
      end
    end
  end
end

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_user(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "users/#{id}"
            )
          end
        end

        class Mock
          def get_user(id)
          end
        end
      end
    end
  end
end

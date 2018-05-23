module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def create_role(role)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "roles",
              :body    => Fog::JSON.encode(:role => role)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

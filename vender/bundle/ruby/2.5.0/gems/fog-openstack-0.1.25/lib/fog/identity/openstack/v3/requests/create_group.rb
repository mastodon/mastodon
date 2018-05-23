module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def create_group(group)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "groups",
              :body    => Fog::JSON.encode(:group => group)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_group(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "groups/#{id}"
            )
          end
        end

        class Mock
          def get_group(id)
          end
        end
      end
    end
  end
end

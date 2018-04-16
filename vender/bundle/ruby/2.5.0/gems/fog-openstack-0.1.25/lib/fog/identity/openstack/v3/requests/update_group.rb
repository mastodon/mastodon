module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_group(id, group)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "groups/#{id}",
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

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_role(id, role)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "roles/#{id}",
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

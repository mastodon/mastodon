module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def update_project(id, project)
            request(
              :expects => [200],
              :method  => 'PATCH',
              :path    => "projects/#{id}",
              :body    => Fog::JSON.encode(:project => project)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

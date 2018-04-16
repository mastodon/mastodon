module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_project(id, options = [])
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "projects/#{id}?#{options.join '&'}"
            )
          end
        end

        class Mock
          def get_domain(id)
          end
        end
      end
    end
  end
end

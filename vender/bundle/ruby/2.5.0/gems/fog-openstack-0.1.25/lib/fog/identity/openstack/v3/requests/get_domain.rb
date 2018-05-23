module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_domain(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "domains/#{id}"
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

module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def get_os_credential(id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "credentials/#{id}"
            )
          end
        end

        class Mock
          def get_os_credential(id)
          end
        end
      end
    end
  end
end

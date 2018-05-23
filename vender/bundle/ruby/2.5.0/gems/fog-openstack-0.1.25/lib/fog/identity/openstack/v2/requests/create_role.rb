module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def create_role(name)
            data = {
              'role' => {
                'name' => name
              }
            }

            request(
              :body    => Fog::JSON.encode(data),
              :expects => [200, 202],
              :method  => 'POST',
              :path    => '/OS-KSADM/roles'
            )
          end
        end

        class Mock
          def create_role(name)
            data = {
              'id'   => Fog::Mock.random_hex(32),
              'name' => name
            }
            self.data[:roles][data['id']] = data
            Excon::Response.new(
              :body   => {'role' => data},
              :status => 202
            )
          end
        end
      end # class V2
    end
  end
end

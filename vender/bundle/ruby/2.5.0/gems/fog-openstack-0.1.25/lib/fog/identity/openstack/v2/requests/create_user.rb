module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def create_user(name, password, email, tenantId = nil, enabled = true)
            data = {
              'user' => {
                'name'     => name,
                'password' => password,
                'tenantId' => tenantId,
                'email'    => email,
                'enabled'  => enabled,
              }
            }

            request(
              :body    => Fog::JSON.encode(data),
              :expects => [200, 202],
              :method  => 'POST',
              :path    => '/users'
            )
          end
        end

        class Mock
          def create_user(name, _password, email, tenantId = nil, enabled = true)
            response = Excon::Response.new
            response.status = 200
            data = {
              'id'       => Fog::Mock.random_hex(32),
              'name'     => name,
              'email'    => email,
              'tenantId' => tenantId,
              'enabled'  => enabled
            }
            self.data[:users][data['id']] = data
            response.body = {'user' => data}
            response
          end
        end
      end # class V2
    end
  end
end

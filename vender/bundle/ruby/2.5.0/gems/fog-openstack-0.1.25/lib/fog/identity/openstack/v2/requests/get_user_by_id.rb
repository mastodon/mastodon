module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def get_user_by_id(user_id)
            request(
              :expects => [200, 203],
              :method  => 'GET',
              :path    => "users/#{user_id}"
            )
          end
        end

        class Mock
          def get_user_by_id(user_id)
            response = Excon::Response.new
            response.status = 200

            existing_user = data[:users].find do |u|
              u[0] == user_id || u[1]['name'] == 'mock'
            end
            existing_user = existing_user[1] if existing_user

            response.body = {
              'user' => existing_user || create_user('mock', 'mock', 'mock@email.com').body['user']
            }
            response
          end
        end
      end # class V2
    end
  end
end

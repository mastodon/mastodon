module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def update_user(user_id, options = {})
            url = options.delete('url') || "/users/#{user_id}"
            request(
              :body    => Fog::JSON.encode('user' => options),
              :expects => 200,
              :method  => 'PUT',
              :path    => url
            )
          end
        end

        class Mock
          def update_user(user_id, options)
            response = Excon::Response.new
            if user = data[:users][user_id]
              if options['name']
                user['name'] = options['name']
              end
              response.status = 200
              response
            else
              raise Fog::Identity::OpenStack::NotFound
            end
          end
        end
      end # class V2
    end
  end
end

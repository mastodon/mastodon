module Fog
  module Compute
    class OpenStack
      class Real
        def update_server(server_id, options = {})
          request(
            :body    => Fog::JSON.encode('server' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "servers/#{server_id}"
          )
        end
      end

      class Mock
        def update_server(server_id, options = {})
          response = Excon::Response.new
          server = list_servers_detail.body['servers'].find { |srv| srv['id'] == server_id }
          if server
            if options['name']
              server['name'] = options['name']
            end
            response.status = 200
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end

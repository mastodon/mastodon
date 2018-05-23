module Fog
  module Compute
    class OpenStack
      class Real
        def get_server_password(server_id)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "servers/#{server_id}/os-server-password"
          )
        end
      end

      class Mock
        def get_server_password(server_id)
          response = Excon::Response.new
          server = list_servers_detail.body['servers'].find { |srv| srv['id'] == server_id }
          if server
            response.status = [200, 203][rand(2)]
            response.body = {'server' => server}
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end

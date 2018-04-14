module Fog
  module Baremetal
    class OpenStack
      class Real
        def delete_port(port_uuid)
          data = {:port_uuid => port_uuid}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 204],
            :method  => 'DELETE',
            :path    => 'ports'
          )
        end
      end

      class Mock
        def delete_port(_port_uuid)
          response = Excon::Response.new
          response.status = 200
          response
        end
      end
    end
  end
end

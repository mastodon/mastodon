module Fog
  module Baremetal
    class OpenStack
      class Real
        def delete_node(node_uuid)
          data = {:node_ident => node_uuid}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 204],
            :method  => 'DELETE',
            :path    => 'nodes'
          )
        end
      end

      class Mock
        def delete_node(_node_uuid)
          response = Excon::Response.new
          response.status = 200
          response
        end
      end
    end
  end
end

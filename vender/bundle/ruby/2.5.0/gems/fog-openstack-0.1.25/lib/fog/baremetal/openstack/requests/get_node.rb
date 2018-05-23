module Fog
  module Baremetal
    class OpenStack
      class Real
        def get_node(node_id)
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "nodes/#{node_id}"
          )
        end
      end # class Real

      class Mock
        def get_node(_node_id)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = data[:nodes].first
          response
        end # def get_node
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog

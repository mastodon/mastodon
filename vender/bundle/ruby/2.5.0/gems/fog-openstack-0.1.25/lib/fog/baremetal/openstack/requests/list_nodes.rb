module Fog
  module Baremetal
    class OpenStack
      class Real
        def list_nodes(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'nodes',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_nodes(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {
            "nodes" => [{
              "instance_uuid"   => Fog::UUID.uuid,
              "maintenance"     => false,
              "power_state"     => "power on",
              "provision_state" => "active",
              "uuid"            => Fog::UUID.uuid,
              "links"           => []
            }]
          }
          response
        end # def list_nodes
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog

module Fog
  module Openstack
    class Planning
      class Real
        def list_roles(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'roles',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_roles(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = [
            {
              "description" => "OpenStack hypervisor node. Can be wrapped in a ResourceGroup for scaling.\n",
              "name"        => "compute",
              "uuid"        => "f72c0656-5696-4c66-81a5-d6d88a48e385",
              "version"     => 1
            }
          ]
          response
        end # def list_nodes
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog

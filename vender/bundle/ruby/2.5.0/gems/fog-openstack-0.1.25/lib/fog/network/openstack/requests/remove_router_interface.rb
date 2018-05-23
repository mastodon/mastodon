module Fog
  module Network
    class OpenStack
      class Real
        def remove_router_interface(router_id, subnet_id, _options = {})
          data = {
            'subnet_id' => subnet_id,
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'PUT',
            :path    => "routers/#{router_id}/remove_router_interface"
          )
        end
      end

      class Mock
        def remove_router_interface(_router_id, _subnet_id, _options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'subnet_id' => 'a2f1f29d-571b-4533-907f-5803ab96ead1'
          }

          self.data[:routers][data['router_id']] = data
          response.body = {'router' => data}
          response
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def get_subnet_pool(subnet_pool_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "subnetpools/#{subnet_pool_id}"
          )
        end
      end

      class Mock
        def get_subnet_pool(subnet_pool_id)
          data = self.data[:subnet_pools][subnet_pool_id]
          if data
            response = Excon::Response.new
            response.status = 200
            response.body = {'subnetpool' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_loadbalancer(loadbalancer_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/loadbalancers/#{loadbalancer_id}"
          )
        end
      end

      class Mock
        def get_lbaas_loadbalancer(loadbalancer_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_loadbalancer][loadbalancer_id]
            response.status = 200
            response.body = {'loadbalancer' => data[:lbaas_loadbalancer]}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

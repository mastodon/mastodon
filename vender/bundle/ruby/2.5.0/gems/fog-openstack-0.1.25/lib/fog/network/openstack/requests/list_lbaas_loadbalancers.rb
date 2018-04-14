module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_loadbalancers(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/loadbalancers',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_loadbalancers(_filters = {})
           Excon::Response.new(
            :body   => {'loadbalancers' => [data[:lbaas_loadbalancer]]},
            :status => 200
          )
        end
      end
    end
  end
end

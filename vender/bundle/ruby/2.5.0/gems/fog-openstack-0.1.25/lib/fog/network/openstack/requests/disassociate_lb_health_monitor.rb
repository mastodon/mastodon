module Fog
  module Network
    class OpenStack
      class Real
        def disassociate_lb_health_monitor(pool_id, health_monitor_id)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "lb/pools/#{pool_id}/health_monitors/#{health_monitor_id}"
          )
        end
      end

      class Mock
        def disassociate_lb_health_monitor(pool_id, health_monitor_id)
          response = Excon::Response.new
          if pool = list_lb_pools.body['pools'].find { |_| _['id'] == pool_id }
            pool['health_monitors'].delete(health_monitor_id)
            data[:lb_pools][pool_id] = pool
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

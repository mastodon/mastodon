module Fog
  module Network
    class OpenStack
      class Real
        def associate_lb_health_monitor(pool_id, health_monitor_id)
          data = {
            'health_monitor' => {
              'id' => health_monitor_id,
            }
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => "lb/pools/#{pool_id}/health_monitors"
          )
        end
      end

      class Mock
        def associate_lb_health_monitor(pool_id, health_monitor_id)
          response = Excon::Response.new
          if pool = list_lb_pools.body['pools'].find { |_| _['id'] == pool_id }
            pool['health_monitors'] << health_monitor_id
            data[:lb_pools][pool_id] = pool
            response.body = {'health_monitor' => {}}
            response.status = 200
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def get_lb_health_monitor(health_monitor_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lb/health_monitors/#{health_monitor_id}"
          )
        end
      end

      class Mock
        def get_lb_health_monitor(health_monitor_id)
          response = Excon::Response.new
          if data = self.data[:lb_health_monitors][health_monitor_id]
            response.status = 200
            response.body = {'health_monitor' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

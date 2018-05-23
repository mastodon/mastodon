module Fog
  module Network
    class OpenStack
      class Real
        def list_lb_health_monitors(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lb/health_monitors',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lb_health_monitors(_filters = {})
          Excon::Response.new(
            :body   => {'health_monitors' => data[:lb_health_monitors].values},
            :status => 200
          )
        end
      end
    end
  end
end

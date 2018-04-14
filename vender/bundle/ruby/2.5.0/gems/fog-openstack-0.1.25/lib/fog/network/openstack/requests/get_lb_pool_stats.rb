module Fog
  module Network
    class OpenStack
      class Real
        def get_lb_pool_stats(pool_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lb/pools/#{pool_id}/stats"
          )
        end
      end

      class Mock
        def get_lb_pool_stats(pool_id)
          response = Excon::Response.new
          if data = self.data[:lb_pools][pool_id]
            stats = {}
            stats["active_connections"] = 0
            stats["bytes_in"] = 0
            stats["bytes_out"] = 0
            stats["total_connections"] = 0
            response.status = 200
            response.body = {'stats' => stats}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

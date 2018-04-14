module Fog
  module Network
    class OpenStack
      class Real
        def get_lb_pool(pool_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lb/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def get_lb_pool(pool_id)
          response = Excon::Response.new
          if data = self.data[:lb_pools][pool_id]
            response.status = 200
            response.body = {'pool' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def delete_lb_pool(pool_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lb/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def delete_lb_pool(pool_id)
          response = Excon::Response.new
          if list_lb_pools.body['pools'].map { |r| r['id'] }.include? pool_id
            data[:lb_pools].delete(pool_id)
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

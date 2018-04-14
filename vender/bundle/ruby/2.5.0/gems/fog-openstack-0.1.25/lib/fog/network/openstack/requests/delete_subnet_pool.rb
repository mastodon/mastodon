module Fog
  module Network
    class OpenStack
      class Real
        def delete_subnet_pool(subnet_pool_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "subnetpools/#{subnet_pool_id}"
          )
        end
      end

      class Mock
        def delete_subnet_pool(subnet_pool_id)
          response = Excon::Response.new
          if list_subnet_pools.body['subnetpools'].map { |r| r['id'] }.include? subnet_pool_id
            data[:subnet_pools].delete(subnet_pool_id)
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

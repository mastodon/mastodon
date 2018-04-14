module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_pool_member(pool_id, member_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/pools/#{pool_id}/members/#{member_id}"
          )
        end
      end

      class Mock
        def get_lbaas_pool_member(pool_id, member_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_pool_members][member_id]
            response.status = 200
            response.body = {'member' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

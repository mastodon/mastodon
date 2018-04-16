module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_pool_member(pool_id, member_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/pools/#{pool_id}/members/#{member_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_pool_member(pool_id, member_id)
          response = Excon::Response.new
          if list_lbaas_pool_members(pool_id).body['members'].map { |r| r['id'] }.include? member_id
            data[:members].delete(member_id)
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

module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_pool_member(pool_id, member_id, options = {})
          data = {'member' => {}}

          vanilla_options = [:weight, :admin_state_up, :name]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['member'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/pools/#{pool_id}/members/#{member_id}"
          )
        end
      end

      class Mock
        def update_lbaas_pool_member(pool_id, member_id, options = {})
          response = Excon::Response.new
          if member = list_lbaas_pool_members.body['members'].find { |_| _['id'] == member_id }
            member['pool_id']        = options[:pool_id]
            member['weight']         = options[:weight]
            member['admin_state_up'] = options[:admin_state_up]
            response.body = {'member' => member}
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

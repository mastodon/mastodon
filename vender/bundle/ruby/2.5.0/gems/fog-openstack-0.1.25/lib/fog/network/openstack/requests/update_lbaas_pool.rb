module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_pool(pool_id, options = {})
          data = {'pool' => {}}

          vanilla_options = [:name, :description, :lb_algorithm, :session_persistence, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['pool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def update_lbaas_pool(pool_id, options = {})
          response = Excon::Response.new
          if pool = list_lbaas_pools.body['pools'].find { |_| _['id'] == pool_id }
            pool['name']            = options[:name]
            pool['description']     = options[:description]
            pool['lb_algorithm']    = options[:lb_algorithm]
            pool['admin_state_up']  = options[:admin_state_up]
            response.body = {'pool' => pool}
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

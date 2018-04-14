module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_pool(listener_id, protocol, lb_algorithm, options = {})
          data = {
            'pool' => {
              'listener_id' => listener_id,
              'protocol'  => protocol,
              'lb_algorithm' => lb_algorithm
            }
          }

          vanilla_options = [:name, :description, :admin_state_up, :session_persistence, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['pool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/pools'
          )
        end
      end

      class Mock
        def create_lbaas_pool(listener_id, protocol, lb_algorithm, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                 => Fog::Mock.random_numbers(6).to_s,
            'protocol'           => protocol,
            'lb_algorithm'       => lb_algorithm,
            'name'               => options[:name],
            'description'        => options[:description],
            'healthmonitor_id'   => Fog::Mock.random_numbers(6).to_s,
            'members'            => [Fog::Mock.random_numbers(6).to_s],
            'status'             => 'ACTIVE',
            'admin_state_up'     => options[:admin_state_up],
            'tenant_id'          => options[:tenant_id],
            'listeners'          => [ 'id' => listener_id ],
            'session_persistence' => {}
          }
          self.data[:lbaas_pools][data['id']] = data
          response.body = {'pool' => data}
          response
        end
      end
    end
  end
end

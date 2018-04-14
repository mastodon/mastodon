module Fog
  module Network
    class OpenStack
      class Real
        def create_lb_pool(subnet_id, protocol, lb_method, options = {})
          data = {
            'pool' => {
              'subnet_id' => subnet_id,
              'protocol'  => protocol,
              'lb_method' => lb_method
            }
          }

          vanilla_options = [:name, :description, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['pool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lb/pools'
          )
        end
      end

      class Mock
        def create_lb_pool(subnet_id, protocol, lb_method, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                 => Fog::Mock.random_numbers(6).to_s,
            'subnet_id'          => subnet_id,
            'protocol'           => protocol,
            'lb_method'          => lb_method,
            'name'               => options[:name],
            'description'        => options[:description],
            'health_monitors'    => [],
            'members'            => [],
            'status'             => 'ACTIVE',
            'admin_state_up'     => options[:admin_state_up],
            'vip_id'             => nil,
            'tenant_id'          => options[:tenant_id],
            'active_connections' => nil,
            'bytes_in'           => nil,
            'bytes_out'          => nil,
            'total_connections'  => nil
          }

          self.data[:lb_pools][data['id']] = data
          response.body = {'pool' => data}
          response
        end
      end
    end
  end
end

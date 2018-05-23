module Fog
  module Network
    class OpenStack
      class Real
        def create_lb_member(pool_id, address, protocol_port, weight, options = {})
          data = {
            'member' => {
              'pool_id'       => pool_id,
              'address'       => address,
              'protocol_port' => protocol_port,
              'weight'        => weight
            }
          }

          vanilla_options = [:admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['member'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lb/members'
          )
        end
      end

      class Mock
        def create_lb_member(pool_id, address, protocol_port, weight, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'             => Fog::Mock.random_numbers(6).to_s,
            'pool_id'        => pool_id,
            'address'        => address,
            'protocol_port'  => protocol_port,
            'weight'         => weight,
            'status'         => 'ACTIVE',
            'admin_state_up' => options[:admin_state_up],
            'tenant_id'      => options[:tenant_id],
          }

          self.data[:lb_members][data['id']] = data
          response.body = {'member' => data}
          response
        end
      end
    end
  end
end

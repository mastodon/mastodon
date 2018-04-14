module Fog
  module Network
    class OpenStack
      class Real
        def create_lb_vip(subnet_id, pool_id, protocol, protocol_port, options = {})
          data = {
            'vip' => {
              'subnet_id'     => subnet_id,
              'pool_id'       => pool_id,
              'protocol'      => protocol,
              'protocol_port' => protocol_port
            }
          }

          vanilla_options = [:name, :description, :address, :session_persistence, :connection_limit,
                             :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['vip'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lb/vips'
          )
        end
      end

      class Mock
        def create_lb_vip(subnet_id,  pool_id, protocol, protocol_port, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                  => Fog::Mock.random_numbers(6).to_s,
            'subnet_id'           => subnet_id,
            'pool_id'             => pool_id,
            'protocol'            => protocol,
            'protocol_port'       => protocol_port,
            'name'                => options[:name],
            'description'         => options[:description],
            'address'             => options[:address],
            'port_id'             => Fog::Mock.random_numbers(6).to_s,
            'session_persistence' => options[:session_persistence],
            'connection_limit'    => options[:connection_limit],
            'status'              => 'ACTIVE',
            'admin_state_up'      => options[:admin_state_up],
            'tenant_id'           => options[:tenant_id],
          }

          self.data[:lb_vips][data['id']] = data
          response.body = {'vip' => data}
          response
        end
      end
    end
  end
end

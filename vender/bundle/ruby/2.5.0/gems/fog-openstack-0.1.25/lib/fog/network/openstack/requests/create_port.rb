module Fog
  module Network
    class OpenStack
      class Real
        def create_port(network_id, options = {})
          data = {
            'port' => {
              'network_id' => network_id,
            }
          }

          vanilla_options = [:name, :fixed_ips, :mac_address, :admin_state_up,
                             :device_owner, :device_id, :tenant_id, :security_groups,
                             :allowed_address_pairs]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['port'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'ports'
          )
        end
      end

      class Mock
        def create_port(network_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                    => Fog::Mock.random_numbers(6).to_s,
            'name'                  => options[:name],
            'network_id'            => network_id,
            'fixed_ips'             => options[:fixed_ips],
            'mac_address'           => options[:mac_address],
            'status'                => 'ACTIVE',
            'admin_state_up'        => options[:admin_state_up],
            'device_owner'          => options[:device_owner],
            'device_id'             => options[:device_id],
            'tenant_id'             => options[:tenant_id],
            'security_groups'       => options[:security_groups],
            'allowed_address_pairs' => options[:allowed_address_pairs],
          }
          self.data[:ports][data['id']] = data
          response.body = {'port' => data}
          response
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def create_floating_ip(floating_network_id, options = {})
          data = {
            'floatingip' => {
              'floating_network_id' => floating_network_id
            }
          }

          vanilla_options = [:port_id, :tenant_id, :fixed_ip_address, :floating_ip_address, :subnet_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['floatingip'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'floatingips'
          )
        end
      end

      class Mock
        def create_floating_ip(floating_network_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                  => floating_network_id,
            'floating_network_id' => floating_network_id,
            'port_id'             => options[:port_id],
            'tenant_id'           => options[:tenant_id],
            'fixed_ip_address'    => options[:fixed_ip_address],
            'router_id'           => nil,
          }
          self.data[:floating_ips][data['id']] = data
          response.body = {'floatingip' => data}
          response
        end
      end
    end
  end
end

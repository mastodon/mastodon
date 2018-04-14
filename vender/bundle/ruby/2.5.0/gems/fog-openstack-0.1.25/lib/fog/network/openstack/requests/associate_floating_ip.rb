module Fog
  module Network
    class OpenStack
      class Real
        def associate_floating_ip(floating_ip_id, port_id, options = {})
          data = {
            'floatingip' => {
              'port_id' => port_id,
            }
          }

          vanilla_options = [:fixed_ip_address]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['floatingip'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'PUT',
            :path    => "floatingips/#{floating_ip_id}"
          )
        end
      end

      class Mock
        def associate_floating_ip(_floating_ip_id, port_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                  => '00000000-0000-0000-0000-000000000000',
            'router_id'           => '00000000-0000-0000-0000-000000000000',
            'tenant_id'           => options["tenant_id"],
            'floating_network_id' => options["floating_network_id"],
            'fixed_ip_address'    => options["fixed_ip_address"],
            'floating_ip_address' => options["floating_ip_address"],
            'port_id'             => port_id,
          }

          self.data[:floating_ips][data['floating_ip_id']] = data
          response.body = {'floatingip' => data}
          response
        end
      end
    end
  end
end

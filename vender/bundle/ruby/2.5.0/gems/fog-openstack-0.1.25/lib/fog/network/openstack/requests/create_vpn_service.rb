module Fog
  module Network
    class OpenStack
      class Real
        def create_vpn_service(subnet_id, router_id, options = {})
          data = {
            'vpnservice' => {
              'subnet_id' => subnet_id,
              'router_id' => router_id
            }
          }

          vanilla_options = [:name, :description, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['vpnservice'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'vpn/vpnservices'
          )
        end
      end

      class Mock
        def create_vpn_service(subnet_id, router_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'             => Fog::Mock.random_numbers(6).to_s,
            'subnet_id'      => subnet_id,
            'router_id'      => router_id,
            'name'           => options[:name],
            'description'    => options[:description],
            'status'         => 'ACTIVE',
            'admin_state_up' => options[:admin_state_up],
            'tenant_id'      => options[:tenant_id],
            'external_v4_ip' => '1.2.3.4',
            'external_v6_ip' => '::1'
          }

          self.data[:vpn_services][data['id']] = data
          response.body = {'vpnservice' => data}
          response
        end
      end
    end
  end
end

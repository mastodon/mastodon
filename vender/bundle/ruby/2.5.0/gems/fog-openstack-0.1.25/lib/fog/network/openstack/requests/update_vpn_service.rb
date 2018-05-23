module Fog
  module Network
    class OpenStack
      class Real
        def update_vpn_service(vpn_service_id, options = {})
          data = {'vpnservice' => {}}

          vanilla_options = [:name, :description, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['vpnservice'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "vpn/vpnservices/#{vpn_service_id}"
          )
        end
      end

      class Mock
        def update_vpn_service(vpn_service_id, options = {})
          response = Excon::Response.new
          if vpn_service = list_vpn_services.body['vpnservices'].detect { |instance| instance['id'] == vpn_service_id }
            vpn_service['id']             = vpn_service_id
            vpn_service['subnet_id']      = options[:subnet_id]
            vpn_service['router_id']      = options[:router_id]
            vpn_service['name']           = options[:name]
            vpn_service['description']    = options[:description]
            vpn_service['status']         = 'ACTIVE'
            vpn_service['admin_state_up'] = options[:admin_state_up]
            vpn_service['tenant_id']      = options[:tenant_id]
            vpn_service['external_v4_ip'] = '1.2.3.4'
            vpn_service['external_v6_ip'] = '::1'
            response.body = {'vpnservice' => vpn_service}
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

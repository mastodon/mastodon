module Fog
  module Network
    class OpenStack
      class Real
        def create_ipsec_site_connection(vpn_service_id, ike_policy_id, ipsec_policy_id, options = {})
          data = {
            'ipsec_site_connection' => {
              'vpnservice_id'  => vpn_service_id,
              'ikepolicy_id'   => ike_policy_id,
              'ipsecpolicy_id' => ipsec_policy_id
            }
          }

          vanilla_options = [:name, :description, :tenant_id,
                             :peer_address, :peer_id, :peer_cidrs,
                             :psk, :mtu, :dpd, :initiator,
                             :admin_state_up]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['ipsec_site_connection'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'vpn/ipsec-site-connections'
          )
        end
      end

      class Mock
        def create_ipsec_site_connection(vpn_service_id, ike_policy_id, ipsec_policy_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                => Fog::Mock.random_numbers(6).to_s,
            'name'              => options[:name],
            'description'       => options[:description],
            'status'            => 'ACTIVE',
            'tenant_id'         => options[:tenant_id],
            'admin_state_up'    => options[:admin_state_up],
            'psk'               => options[:psk],
            'initiator'         => options[:initiator],
            'auth_mode'         => "psk",
            'peer_cidrs'        => options[:peer_cidrs],
            'mtu'               => options[:mtu],
            'peer_ep_group_id'  => Fog::Mock.random_numbers(6).to_s,
            'ikepolicy_id'      => ike_policy_id,
            'vpnservice_id'     => vpn_service_id,
            'dpd'               => options[:dpd],
            'route_mode'        => "static",
            'ipsecpolicy_id'    => ipsec_policy_id,
            'local_ep_group_id' => Fog::Mock.random_numbers(6).to_s,
            'peer_address'      => options[:peer_address],
            'peer_id'           => options[:peer_id]
          }

          self.data[:ipsec_site_connections][data['id']] = data
          response.body = {'ipsec_site_connection' => data}
          response
        end
      end
    end
  end
end

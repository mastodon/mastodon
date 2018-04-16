module Fog
  module Network
    class OpenStack
      class Real
        def update_ipsec_site_connection(ipsec_site_connection_id, options = {})
          data = {'ipsec_site_connection' => {}}

          vanilla_options = [:name, :description, :tenant_id,
                             :peer_address, :peer_id, :peer_cidrs,
                             :psk, :mtu, :dpd, :initiator,
                             :admin_state_up, :ikepolicy_id,
                             :ipsecpolicy_id, :vpnservice_id]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['ipsec_site_connection'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "vpn/ipsec-site-connections/#{ipsec_site_connection_id}"
          )
        end
      end

      class Mock
        def update_ipsec_site_connection(ipsec_site_connection_id, options = {})
          response = Excon::Response.new
          ipsec_site_connection = list_ipsec_site_connections.body['ipsec_site_connections'].detect do |instance|
            instance['id'] == ipsec_site_connection_id
          end
          if ipsec_site_connection
            ipsec_site_connection['name']              = options[:name]
            ipsec_site_connection['description']       = options[:description]
            ipsec_site_connection['tenant_id']         = options[:tenant_id]
            ipsec_site_connection['status']            = 'ACTIVE'
            ipsec_site_connection['admin_state_up']    = options[:admin_state_up]
            ipsec_site_connection['psk']               = options[:psk]
            ipsec_site_connection['initiator']         = options[:initiator]
            ipsec_site_connection['auth_mode']         = "psk"
            ipsec_site_connection['peer_cidrs']        = options[:peer_cidrs]
            ipsec_site_connection['mtu']               = options[:mtu]
            ipsec_site_connection['peer_ep_group_id']  = Fog::Mock.random_numbers(6).to_s
            ipsec_site_connection['ikepolicy_id']      = options[:ikepolicy_id] || 'ike'
            ipsec_site_connection['vpnservice_id']     = options[:vpnservice_id] || 'vpn'
            ipsec_site_connection['dpd']               = options[:dpd]
            ipsec_site_connection['route_mode']        = "static"
            ipsec_site_connection['ipsecpolicy_id']    = options[:ipsecpolicy_id] || 'ipsec'
            ipsec_site_connection['local_ep_group_id'] = Fog::Mock.random_numbers(6).to_s
            ipsec_site_connection['peer_address']      = options[:peer_address]
            ipsec_site_connection['peer_id']           = options[:peer_id]

            response.body = {'ipsec_site_connection' => ipsec_site_connection}
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

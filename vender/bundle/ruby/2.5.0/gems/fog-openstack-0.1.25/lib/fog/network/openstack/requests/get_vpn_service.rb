module Fog
  module Network
    class OpenStack
      class Real
        def get_vpn_service(vpn_service_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "vpn/vpnservices/#{vpn_service_id}"
          )
        end
      end

      class Mock
        def get_vpn_service(vpn_service_id)
          response = Excon::Response.new
          if data = self.data[:vpn_services][vpn_service_id]
            response.status = 200
            response.body   = {'vpnservice' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

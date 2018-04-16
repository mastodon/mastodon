module Fog
  module Network
    class OpenStack
      class Real
        def delete_vpn_service(vpn_service_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "vpn/vpnservices/#{vpn_service_id}"
          )
        end
      end

      class Mock
        def delete_vpn_service(vpn_service_id)
          response = Excon::Response.new
          if list_vpn_services.body['vpnservices'].collect { |r| r['id'] }.include? vpn_service_id
            data[:vpn_services].delete(vpn_service_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def delete_ipsec_site_connection(ipsec_site_connection_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "vpn/ipsec-site-connections/#{ipsec_site_connection_id}"
          )
        end
      end

      class Mock
        def delete_ipsec_site_connection(ipsec_site_connection_id)
          response = Excon::Response.new
          ip_site_connections = list_ipsec_site_connections.body['ipsec_site_connections']
          if ip_site_connections.collect { |r| r['id'] }.include? ipsec_site_connection_id
            data[:ipsec_site_connections].delete(ipsec_site_connection_id)
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

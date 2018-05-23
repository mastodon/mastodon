module Fog
  module Network
    class OpenStack
      class Real
        def get_ipsec_site_connection(ipsec_site_connection_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "vpn/ipsec-site-connections/#{ipsec_site_connection_id}"
          )
        end
      end

      class Mock
        def get_ipsec_site_connection(ipsec_site_connection_id)
          response = Excon::Response.new
          if data = self.data[:ipsec_site_connections][ipsec_site_connection_id]
            response.status = 200
            response.body   = {'ipsec_site_connection' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

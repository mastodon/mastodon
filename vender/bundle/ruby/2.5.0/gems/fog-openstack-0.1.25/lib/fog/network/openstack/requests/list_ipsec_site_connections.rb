module Fog
  module Network
    class OpenStack
      class Real
        def list_ipsec_site_connections(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'vpn/ipsec-site-connections',
            :query   => filters
          )
        end
      end

      class Mock
        def list_ipsec_site_connections(*)
          Excon::Response.new(
            :body   => {'ipsec_site_connections' => data[:ipsec_site_connections].values},
            :status => 200
          )
        end
      end
    end
  end
end

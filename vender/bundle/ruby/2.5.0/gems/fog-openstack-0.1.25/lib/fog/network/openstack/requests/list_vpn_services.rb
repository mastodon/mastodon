module Fog
  module Network
    class OpenStack
      class Real
        def list_vpn_services(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'vpn/vpnservices',
            :query   => filters
          )
        end
      end

      class Mock
        def list_vpn_services(*)
          Excon::Response.new(
            :body   => {'vpnservices' => data[:vpn_services].values},
            :status => 200
          )
        end
      end
    end
  end
end

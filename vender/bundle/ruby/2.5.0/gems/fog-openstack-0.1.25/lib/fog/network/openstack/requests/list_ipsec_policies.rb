module Fog
  module Network
    class OpenStack
      class Real
        def list_ipsec_policies(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'vpn/ipsecpolicies',
            :query   => filters
          )
        end
      end

      class Mock
        def list_ipsec_policies(*)
          Excon::Response.new(
            :body   => {'ipsecpolicies' => data[:ipsec_policies].values},
            :status => 200
          )
        end
      end
    end
  end
end

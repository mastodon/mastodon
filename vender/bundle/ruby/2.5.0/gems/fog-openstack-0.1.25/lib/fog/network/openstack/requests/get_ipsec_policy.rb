module Fog
  module Network
    class OpenStack
      class Real
        def get_ipsec_policy(ipsec_policy_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "vpn/ipsecpolicies/#{ipsec_policy_id}"
          )
        end
      end

      class Mock
        def get_ipsec_policy(ipsec_policy_id)
          response = Excon::Response.new
          if data = self.data[:ipsec_policies][ipsec_policy_id]
            response.status = 200
            response.body   = {'ipsecpolicy' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

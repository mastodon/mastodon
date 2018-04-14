module Fog
  module Network
    class OpenStack
      class Real
        def delete_ipsec_policy(ipsec_policy_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "vpn/ipsecpolicies/#{ipsec_policy_id}"
          )
        end
      end

      class Mock
        def delete_ipsec_policy(ipsec_policy_id)
          response = Excon::Response.new
          if list_ipsec_policies.body['ipsecpolicies'].collect { |r| r['id'] }.include? ipsec_policy_id
            data[:ipsec_policies].delete(ipsec_policy_id)
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

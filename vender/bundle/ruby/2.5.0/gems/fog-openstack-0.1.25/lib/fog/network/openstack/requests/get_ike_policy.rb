module Fog
  module Network
    class OpenStack
      class Real
        def get_ike_policy(ike_policy_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "vpn/ikepolicies/#{ike_policy_id}"
          )
        end
      end

      class Mock
        def get_ike_policy(ike_policy_id)
          response = Excon::Response.new
          if data = self.data[:ike_policies][ike_policy_id]
            response.status = 200
            response.body   = {'ikepolicy' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

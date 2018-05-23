module Fog
  module Network
    class OpenStack
      class Real
        def delete_ike_policy(ike_policy_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "vpn/ikepolicies/#{ike_policy_id}"
          )
        end
      end

      class Mock
        def delete_ike_policy(ike_policy_id)
          response = Excon::Response.new
          if list_ike_policies.body['ikepolicies'].collect { |r| r['id'] }.include? ike_policy_id
            data[:ike_policies].delete(ike_policy_id)
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

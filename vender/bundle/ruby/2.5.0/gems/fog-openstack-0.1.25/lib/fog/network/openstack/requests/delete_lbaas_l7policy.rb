module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_l7policy(l7policy_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/l7policies/#{l7policy_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_l7policy(l7policy_id)
          response = Excon::Response.new
          if list_lbaas_l7policies.body['l7policies'].map { |r| r['id'] }.include? l7policy_id
            data[:lbaas_l7policies].delete(l7policy_id)
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

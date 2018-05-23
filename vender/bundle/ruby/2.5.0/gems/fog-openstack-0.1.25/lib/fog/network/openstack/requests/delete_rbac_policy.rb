module Fog
  module Network
    class OpenStack
      class Real
        def delete_rbac_policy(rbac_policy_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "rbac-policies/#{rbac_policy_id}"
          )
        end
      end

      class Mock
        def delete_rbac_policy(rbac_policy_id)
          response = Excon::Response.new
          if list_rbac_policies.body['rbac_policies'].collect { |r| r['id'] }.include? rbac_policy_id
            data[:rbac_policies].delete(rbac_policy_id)
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

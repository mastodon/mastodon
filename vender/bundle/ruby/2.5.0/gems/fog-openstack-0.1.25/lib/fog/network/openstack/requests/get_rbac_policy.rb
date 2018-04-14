module Fog
  module Network
    class OpenStack
      class Real
        def get_rbac_policy(rbac_policy_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "rbac-policies/#{rbac_policy_id}"
          )
        end
      end

      class Mock
        def get_rbac_policy(rbac_policy_id)
          response = Excon::Response.new
          if data = self.data[:rbac_policies][rbac_policy_id]
            response.status = 200
            response.body   = {'rbac_policy' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

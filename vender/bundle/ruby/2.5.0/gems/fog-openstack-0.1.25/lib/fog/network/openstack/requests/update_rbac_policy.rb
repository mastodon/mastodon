module Fog
  module Network
    class OpenStack
      class Real
        def update_rbac_policy(rbac_policy_id, options = {})
          data = {'rbac_policy' => {}}

          vanilla_options = [:target_tenant]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['rbac_policy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "rbac-policies/#{rbac_policy_id}"
          )
        end
      end

      class Mock
        def update_rbac_policy(rbac_policy_id, options = {})
          response = Excon::Response.new
          rbac_policy = list_rbac_policies.body['rbac_policies'].detect do |instance|
            instance['id'] == rbac_policy_id
          end
          if rbac_policy
            rbac_policy['target_tenant'] = options[:target_tenant]

            response.body = {'rbac_policy' => rbac_policy}
            response.status = 200
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

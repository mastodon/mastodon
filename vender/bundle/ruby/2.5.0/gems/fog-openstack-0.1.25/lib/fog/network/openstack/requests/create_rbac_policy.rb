module Fog
  module Network
    class OpenStack
      class Real
        def create_rbac_policy(options = {})
          data = {'rbac_policy' => {}}

          vanilla_options = [:object_type, :object_id, :tenant_id, :target_tenant, :action]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['rbac_policy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'rbac-policies'
          )
        end
      end

      class Mock
        def create_rbac_policy(options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'            => Fog::Mock.random_numbers(6).to_s,
            'object_type'   => options[:object_type],
            'object_id'     => options[:object_id],
            'tenant_id'     => options[:tenant_id],
            'target_tenant' => options[:target_tenant],
            'action'        => options[:action]
          }

          self.data[:rbac_policies][data['id']] = data
          response.body = {'rbac_policy' => data}
          response
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_l7rule(l7policy_id, type, compare_type, value, options = {})
          data = {
            'rule' => {
              'type'          => type,
              'compare_type'  => compare_type,
              'value'         => value
            }
          }

          vanilla_options = [:tenant_id, :key, :invert]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['rule'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => "lbaas/l7policies/#{l7policy_id}/rules"
          )
        end
      end

      class Mock
        def create_lbaas_l7rule(l7policy_id, type, compare_type, value, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'              => Fog::Mock.random_numbers(6).to_s,
            'type'            => type,
            'compare_type'    => compare_type,
            'value'           => value,
            'tenant_id'       => options[:tenant_id],
            'key'             => options[:key],
            'invert'          => options[:invert],
            'l7policy_id'     => l7policy_id
          }

          self.data[:lbaas_l7rules][data['id']] = data
          response.body = {'rule' => data}
          response
        end
      end
    end
  end
end

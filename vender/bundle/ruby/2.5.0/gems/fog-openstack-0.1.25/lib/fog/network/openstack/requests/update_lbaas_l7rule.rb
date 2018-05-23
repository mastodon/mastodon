module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_l7rule(l7policy_id, l7rule_id, options = {})

          data = { 'rule' => {} }

          vanilla_options = [:type, :compare_type, :key, :value, :invert]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['rule'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'PUT',
            :path    => "lbaas/l7policies/#{l7policy_id}/rules/#{l7rule_id}"
          )
        end
      end

      class Mock
        def update_lbaas_l7rule(l7policy_id, l7rule_id, options = {})
          response = Excon::Response.new
          if l7rule = list_l7rules.body['l7rules'].find { |_| _['id'] == l7rule_id }
            l7rule['type']           = options[:type]
            l7rule['compare_type']   = options[:compare_type]
            l7rule['key']            = options[:key]
            l7rule['value']          = options[:value]
            l7rule['invert']         = options[:invert]
            response.body = {'rule' => l7rule}
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

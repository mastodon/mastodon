module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_l7policy(l7policy_id, options = {})

          data = {'l7policy' => {}}

          vanilla_options = [:action, :name, :description, :redirect_pool_id, :redirect_url, :position]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['l7policy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'PUT',
            :path    => "lbaas/l7policies/#{l7policy_id}"
          )
        end
      end

      class Mock
        def update_lbaas_l7rule(l7policy_id, options = {})
          response = Excon::Response.new
          if l7policy = list_l7policies.body['l7policies'].find { |_| _['id'] == l7policy_id }
            l7policy['action']        = options[:action]
            l7policy['name']          = options[:name]
            l7policy['description']   = options[:description]
            l7policy['redirect_pool_id'] = options[:redirect_pool_id]
            l7policy['redirect_url']  = options[:redirect_url]
            l7policy['position']      = options[:position]
            response.body = {'l7policy' => l7policy}
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

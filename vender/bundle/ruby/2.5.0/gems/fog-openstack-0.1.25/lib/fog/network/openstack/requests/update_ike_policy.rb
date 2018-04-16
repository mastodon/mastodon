module Fog
  module Network
    class OpenStack
      class Real
        def update_ike_policy(ike_policy_id, options = {})
          data = {'ikepolicy' => {}}

          vanilla_options = [:name, :description, :tenant_id,
                             :auth_algorithm, :encryption_algorithm,
                             :pfs, :phase1_negotiation_mode,
                             :lifetime, :ike_version]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['ikepolicy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "vpn/ikepolicies/#{ike_policy_id}"
          )
        end
      end

      class Mock
        def update_ike_policy(ike_policy_id, options = {})
          response = Excon::Response.new
          if ike_policy = list_ike_policies.body['ikepolicies'].detect { |instance| instance['id'] == ike_policy_id }
            ike_policy['name']                    = options[:name]
            ike_policy['description']             = options[:description]
            ike_policy['tenant_id']               = options[:tenant_id]
            ike_policy['auth_algorithm']          = options[:auth_algorithm]
            ike_policy['encryption_algorithm']    = options[:encryption_algorithm]
            ike_policy['pfs']                     = options[:pfs]
            ike_policy['phase1_negotiation_mode'] = options[:phase1_negotiation_mode]
            ike_policy['lifetime']                = options[:lifetime]
            ike_policy['ike_version']             = options[:ike_version]
            response.body = {'ikepolicy' => ike_policy}
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

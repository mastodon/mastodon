module Fog
  module Network
    class OpenStack
      class Real
        def update_ipsec_policy(ipsec_policy_id, options = {})
          data = {'ipsecpolicy' => {}}

          vanilla_options = [:name, :description, :tenant_id,
                             :auth_algorithm, :encryption_algorithm,
                             :pfs, :transform_protocol, :encapsulation_mode,
                             :lifetime, :ipsec_version]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['ipsecpolicy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "vpn/ipsecpolicies/#{ipsec_policy_id}"
          )
        end
      end

      class Mock
        def update_ipsec_policy(ipsec_policy_id, options = {})
          response = Excon::Response.new
          ipsec_policy = list_ipsec_policies.body['ipsecpolicies'].detect do |instance|
            instance['id'] == ipsec_policy_id
          end
          if ipsec_policy
            ipsec_policy['name']                 = options[:name]
            ipsec_policy['description']          = options[:description]
            ipsec_policy['tenant_id']            = options[:tenant_id]
            ipsec_policy['auth_algorithm']       = options[:auth_algorithm]
            ipsec_policy['encryption_algorithm'] = options[:encryption_algorithm]
            ipsec_policy['pfs']                  = options[:pfs]
            ipsec_policy['transform_protocol']   = options[:transform_protocol]
            ipsec_policy['encapsulation_mode']   = options[:encapsulation_mode]
            ipsec_policy['lifetime']             = options[:lifetime]
            response.body = {'ipsecpolicy' => ipsec_policy}
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

module Fog
  module Network
    class OpenStack
      class Real
        def create_ipsec_policy(options = {})
          data = {
            'ipsecpolicy' => {
            }
          }

          vanilla_options = [:name, :description, :tenant_id,
                             :auth_algorithm, :encryption_algorithm,
                             :pfs, :transform_protocol,
                             :lifetime, :encapsulation_mode]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['ipsecpolicy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'vpn/ipsecpolicies'
          )
        end
      end

      class Mock
        def create_ipsec_policy(options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                   => Fog::Mock.random_numbers(6).to_s,
            'name'                 => options[:name],
            'description'          => options[:description],
            'tenant_id'            => options[:tenant_id],
            'auth_algorithm'       => options[:auth_algorithm],
            'encryption_algorithm' => options[:encryption_algorithm],
            'pfs'                  => options[:pfs],
            'transform_protocol'   => options[:transform_protocol],
            'lifetime'             => options[:lifetime],
            'encapsulation_mode'   => options[:encapsulation_mode]
          }

          self.data[:ipsec_policies][data['id']] = data
          response.body = {'ipsecpolicy' => data}
          response
        end
      end
    end
  end
end

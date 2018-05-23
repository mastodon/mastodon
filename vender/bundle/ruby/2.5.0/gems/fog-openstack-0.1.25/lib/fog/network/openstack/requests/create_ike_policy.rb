module Fog
  module Network
    class OpenStack
      class Real
        def create_ike_policy(options = {})
          data = {
            'ikepolicy' => {
            }
          }

          vanilla_options = [:name, :description, :tenant_id,
                             :auth_algorithm, :encryption_algorithm,
                             :pfs, :phase1_negotiation_mode,
                             :lifetime, :ike_version]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['ikepolicy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'vpn/ikepolicies'
          )
        end
      end

      class Mock
        def create_ike_policy(options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                      => Fog::Mock.random_numbers(6).to_s,
            'name'                    => options[:name],
            'description'             => options[:description],
            'tenant_id'               => options[:tenant_id],
            'auth_algorithm'          => options[:auth_algorithm],
            'encryption_algorithm'    => options[:encryption_algorithm],
            'pfs'                     => options[:pfs],
            'phase1_negotiation_mode' => options[:phase1_negotiation_mode],
            'lifetime'                => options[:lifetime],
            'ike_version'             => options[:ike_version]
          }

          self.data[:ike_policies][data['id']] = data
          response.body = {'ikepolicy' => data}
          response
        end
      end
    end
  end
end

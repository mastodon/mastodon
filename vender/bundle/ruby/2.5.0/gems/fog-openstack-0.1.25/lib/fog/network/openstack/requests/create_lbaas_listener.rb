module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_listener(loadbalancer_id, protocol, protocol_port, options = {})
          data = {
            'listener' => {
              'loadbalancer_id' => loadbalancer_id,
              'protocol'        => protocol,
              'protocol_port'   => protocol_port
            }
          }

          vanilla_options = [:name, :description, :default_pool_id, :connection_limit, :default_tls_container_ref, :sni_container_refs,
                             :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['listener'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/listeners'
          )
        end
      end

      class Mock
        def create_lbaas_listener(loadbalancer_id, protocol, protocol_port, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                      => Fog::Mock.random_numbers(6).to_s,
            'loadbalancers'           =>  [{'id' =>  loadbalancer_id }],
            'protocol'                => protocol,
            'protocol_port'           => protocol_port,
            'name'                    => options[:name],
            'description'             => options[:description],
            'default_pool_id'         => options[:default_pool_id],
            'connection_limit'        => options[:connection_limit],
            'default_tls_container_ref' => options[:default_tls_container_ref],
            'sni_container_refs'      => options[:sni_container_refs],
            'admin_state_up'          => options[:admin_state_up],
            'tenant_id'               => options[:tenant_id]
          }

          self.data[:lbaas_listener][data['id']] = data
          response.body = {'listener' => data}
          response
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_listener(listener_id, options = {})

          data = { 'listener' => {} }

          vanilla_options = [:name, :description, :connection_limit, :default_tls_container_ref, :sni_container_refs,
                             :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['listener'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/listeners/#{listener_id}"
          )
        end
      end

      class Mock
        def update_lbaas_listener(listener_id, options = {})
          response = Excon::Response.new
          if listener = list_lbaas_listeners.body['listeners'].find { |_| _['id'] == listener_id }
            listener['name']                = options[:name]
            listener['description']         = options[:description]
            listener['connection_limit']    = options[:connection_limit]
            listener['default_tls_container_ref']    = options[:default_tls_container_ref]
            listener['sni_container_refs']  = options[:sni_container_refs]
            listener['admin_state_up']      = options[:admin_state_up]
            response.body = {'listener' => listener}
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

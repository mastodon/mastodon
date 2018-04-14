module Fog
  module Network
    class OpenStack
      class Real
        # Not all options can be updated
        UPDATE_OPTIONS = [
          :name,
          :shared,
          :admin_state_up,
          :qos_policy_id,
          :port_security_enabled
        ].freeze

        # Not all extra options can be updated
        UPDATE_EXTENTED_OPTIONS = [
          :router_external
        ].freeze

        def self.update(options)
          data = {}
          UPDATE_OPTIONS.select { |o| options.key?(o) }.each do |key|
            data[key.to_s] = options[key]
          end

          UPDATE_EXTENTED_OPTIONS.reject { |o| options[o].nil? }.each do |key|
            aliased_key = ALIASES[key] || key
            data[aliased_key] = options[key]
          end
          data
        end

        def update_network(network_id, options = {})
          data = {'network' => self.class.update(options)}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "networks/#{network_id}.json"
          )
        end
      end

      class Mock
        def update_network(network_id, options = {})
          response = Excon::Response.new
          if network = list_networks.body['networks'].find { |_| _['id'] == network_id }
            network.merge!(Fog::Network::OpenStack::Real.update(options))
            response.body = {'network' => network}
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

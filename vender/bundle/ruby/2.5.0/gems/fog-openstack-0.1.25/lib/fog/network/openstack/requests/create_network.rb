module Fog
  module Network
    class OpenStack
      class Real
        CREATE_OPTIONS = [
          :name,
          :shared,
          :admin_state_up,
          :qos_policy_id,
          :port_security_enabled,
          :tenant_id,
        ].freeze

        # Advanced Features through API Extensions
        #
        # Not strictly required but commonly found in OpenStack
        # installs with Quantum networking.
        #
        # @see http://docs.openstack.org/trunk/openstack-network/admin/content/provider_attributes.html

        EXTENTED_OPTIONS = [
          :provider_network_type,
          :provider_segmentation_id,
          :provider_physical_network,
          :router_external,
        ].freeze

        # Map Fog::Network::OpenStack::Network
        # model attributes to OpenStack provider attributes
        ALIASES = {
          :provider_network_type     => 'provider:network_type',

          # Not applicable to the "local" or "gre" network types
          :provider_physical_network => 'provider:physical_network',
          :provider_segmentation_id  => 'provider:segmentation_id',

          :router_external           => 'router:external'
        }.freeze

        def self.create(options)
          data = {}
          CREATE_OPTIONS.reject { |o| options[o].nil? }.each do |key|
            data[key.to_s] = options[key]
          end

          EXTENTED_OPTIONS.reject { |o| options[o].nil? }.each do |key|
            aliased_key = ALIASES[key] || key
            data[aliased_key] = options[key]
          end
          data
        end

        def create_network(options = {})
          data = {}
          data['network'] = self.class.create(options)
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'networks'
          )
        end
      end

      class Mock
        def create_network(options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                    => Fog::Mock.random_numbers(6).to_s,
            'name'                  => options[:name],
            'shared'                => options[:shared] || false,
            'subnets'               => [],
            'status'                => 'ACTIVE',
            'admin_state_up'        => options[:admin_state_up] || false,
            'tenant_id'             => options[:tenant_id],
            'qos_policy_id'         => options[:qos_policy_id],
            'port_security_enabled' => options[:port_security_enabled] || false
          }
          data.merge!(Fog::Network::OpenStack::Real.create(options))
          self.data[:networks][data['id']] = data
          response.body = {'network' => data}
          response
        end
      end
    end
  end
end

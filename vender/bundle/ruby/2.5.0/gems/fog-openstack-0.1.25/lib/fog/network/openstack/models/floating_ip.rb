require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class FloatingIp < Fog::OpenStack::Model
        identity :id

        attribute :floating_network_id
        attribute :port_id
        attribute :tenant_id
        attribute :router_id
        attribute :fixed_ip_address
        attribute :floating_ip_address

        def initialize(attributes)
          @connection = attributes[:connection]
          super
        end

        def create
          requires :floating_network_id
          merge_attributes(service.create_floating_ip(floating_network_id,

                                                      attributes).body['floatingip'])
          self
        end

        def update
          self
        end

        def destroy
          requires :id
          service.delete_floating_ip(id)
          true
        end

        def associate(port_id, fixed_ip_address = nil)
          requires :id
          merge_attributes(service.associate_floating_ip(
            id,
            port_id,
            options(fixed_ip_address)
          ).body['floatingip'])
        end

        def disassociate(fixed_ip_address = nil)
          requires :id
          merge_attributes(service.disassociate_floating_ip(
            id,
            options(fixed_ip_address)
          ).body['floatingip'])
        end

        private

        def options(fixed_ip_address)
          fixed_ip_address ? {'fixed_ip_address' => fixed_ip_address} : {}
        end
      end
    end
  end
end

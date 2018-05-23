require 'fog/openstack/models/model'

module Fog
  module Baremetal
    class OpenStack
      class Node < Fog::OpenStack::Model
        identity :uuid

        attribute :instance_uuid
        attribute :maintenance
        attribute :power_state
        attribute :provision_state
        attribute :uuid

        # detailed
        attribute :created_at
        attribute :updated_at
        attribute :chassis_uuid
        attribute :console_enabled
        attribute :driver
        attribute :driver_info
        attribute :extra
        attribute :instance_info
        attribute :last_error
        attribute :maintenance_reason
        attribute :properties
        attribute :provision_updated_at
        attribute :reservation
        attribute :target_power_state
        attribute :target_provision_state

        def create
          requires :driver
          merge_attributes(service.create_node(attributes).body)
          self
        end

        def update(patch = nil)
          requires :uuid, :driver
          if patch
            merge_attributes(service.patch_node(uuid, patch).body)
          else
            # TODO: implement update_node method using PUT method and self.attributes
            # once it is supported by Ironic
            raise ArgumentError,
                  'You need to provide patch attribute. Ironic does not support update by hash yet, only by jsonpatch.'
          end
          self
        end

        def destroy
          requires :uuid
          service.delete_node(uuid)
          true
        end

        def chassis
          requires :uuid
          service.get_chassis(chassis_uuid).body
        end

        def ports
          requires :uuid
          service.list_ports_detailed(:node_uuid => uuid).body['ports']
        end

        def set_node_maintenance(parameters = nil)
          requires :uuid
          service.set_node_maintenance(uuid, parameters)
          true
        end

        def unset_node_maintenance(parameters = nil)
          requires :uuid
          service.unset_node_maintenance(uuid, parameters)
          true
        end

        def metadata
          requires :uuid
          service.get_node(uuid).headers
        end

        def set_power_state(power_state)
          requires :uuid
          service.set_node_power_state(uuid, power_state)
        end

        def set_provision_state(provision_state)
          requires :uuid
          service.set_node_provision_state(uuid, provision_state)
        end
      end
    end
  end
end

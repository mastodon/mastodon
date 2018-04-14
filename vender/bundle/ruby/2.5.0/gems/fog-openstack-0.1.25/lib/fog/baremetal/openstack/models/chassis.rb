require 'fog/openstack/models/model'

module Fog
  module Baremetal
    class OpenStack
      class Chassis < Fog::OpenStack::Model
        identity :uuid

        attribute :description
        attribute :uuid

        # detailed
        attribute :created_at
        attribute :updated_at
        attribute :extra

        def create
          requires :description
          merge_attributes(service.create_chassis(attributes).body)
          self
        end

        def update(patch = nil)
          requires :uuid, :description
          if patch
            merge_attributes(service.patch_chassis(uuid, patch).body)
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
          service.delete_chassis(uuid)
          true
        end

        def metadata
          requires :uuid
          service.get_chassis(uuid).headers
        end
      end
    end
  end
end

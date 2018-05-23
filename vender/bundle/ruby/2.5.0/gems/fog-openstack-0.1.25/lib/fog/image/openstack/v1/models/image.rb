require 'fog/openstack/models/model'

module Fog
  module Image
    class OpenStack
      class V1
        class Image < Fog::OpenStack::Model
          identity :id

          attribute :name
          attribute :size
          attribute :disk_format
          attribute :container_format
          attribute :id
          attribute :checksum

          # detailed
          attribute :min_disk
          attribute :created_at
          attribute :deleted_at
          attribute :updated_at
          attribute :deleted
          attribute :protected
          attribute :is_public
          attribute :status
          attribute :min_ram
          attribute :owner
          attribute :properties
          attribute :location
          attribute :copy_from

          def create
            requires :name
            merge_attributes(service.create_image(attributes).body['image'])
            self
          end

          def update
            requires :name
            merge_attributes(service.update_image(attributes).body['image'])
            self
          end

          def destroy
            requires :id
            service.delete_image(id)
            true
          end

          def add_member(member_id)
            requires :id
            service.add_member_to_image(id, member_id)
          end

          def remove_member(member_id)
            requires :id
            service.remove_member_from_image(id, member_id)
          end

          def update_members(members)
            requires :id
            service.update_image_members(id, members)
          end

          def members
            requires :id
            service.get_image_members(id).body['members']
          end

          def metadata
            requires :id
            service.get_image(id).headers
          end
        end
      end
    end
  end
end

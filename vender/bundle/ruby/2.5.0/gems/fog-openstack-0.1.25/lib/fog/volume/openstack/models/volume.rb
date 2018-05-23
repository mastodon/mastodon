require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class Volume < Fog::OpenStack::Model
        attribute :metadata
        attribute :status
        attribute :size
        attribute :volume_type, :aliases => %w(volumeType type)
        attribute :snapshot_id, :aliases => 'snapshotId'
        attribute :imageRef, :aliases => 'image_id'
        attribute :availability_zone, :aliases => 'availabilityZone'
        attribute :created_at, :aliases => 'createdAt'
        attribute :attachments
        attribute :source_volid

        def destroy
          requires :id
          service.delete_volume(id)
          true
        end

        def extend(size)
          requires :id
          service.extend_volume(id, size)
          true
        end

        def ready?
          status == 'available'
        end

        def reset_status(status)
          requires :id
          service.action(id, 'os-reset_status' => {:status => status})
        end

        def create_metadata(metadata)
          replace_metadata(metadata)
        end

        # Existing keys have values updated and new key-value pairs are created, but none are deleted
        def update_metadata(metadata)
          requires :id
          service.update_metadata(id, metadata)
          true
        end

        # All existing key-value pairs are deleted and replaced with the key-value pairs specified here
        def replace_metadata(metadata)
          requires :id
          service.replace_metadata(id, metadata)
          true
        end

        # Delete one specific key-value pair by specifying the key name
        def delete_metadata(key_name)
          requires :id
          service.delete_metadata(id, key_name)
          true
        end
      end
    end
  end
end

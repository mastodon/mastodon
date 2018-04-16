require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class Backup < Fog::OpenStack::Model
        attribute :availability_zone
        attribute :container
        attribute :created_at
        attribute :description
        attribute :fail_reason
        attribute :name
        attribute :object_count
        attribute :size
        attribute :status
        attribute :volume_id
        attribute :is_incremental
        attribute :has_dependent_backups

        def create
          requires :name, :volume_id
          data = service.create_backup(attributes)
          merge_attributes(data.body['backup'])
          true
        end

        def destroy
          requires :id
          service.delete_backup(id)
          true
        end

        def restore(volume_id)
          requires :id
          service.restore_backup(id, volume_id)
          true
        end

        def volume
          requires :id
          service.get_volume_details(volume_id).body['volume']
        end
      end
    end
  end
end

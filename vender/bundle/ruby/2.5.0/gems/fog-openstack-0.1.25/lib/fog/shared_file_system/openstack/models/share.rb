require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class Share < Fog::OpenStack::Model
        identity :id

        attribute :share_proto
        attribute :size
        attribute :status
        attribute :links
        attribute :share_type
        attribute :share_type_name
        attribute :availability_zone
        attribute :share_network_id
        attribute :share_server_id
        attribute :host
        attribute :snapshot_id
        attribute :snapshot_support
        attribute :task_state
        attribute :access_rules_status
        attribute :has_replicas
        attribute :consistency_group_id
        attribute :source_cgsnapshot_member_id
        attribute :project_id
        attribute :created_at

        # optional
        attribute :name
        attribute :description
        attribute :export_location
        attribute :export_locations
        attribute :metadata
        attribute :is_public
        attribute :volume_type

        def save
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          requires :size, :share_proto
          merge_attributes(service.create_share(share_proto, size, attributes).body['share'])
          true
        end

        def update(options = nil)
          requires :id
          merge_attributes(service.update_share(id, options || attributes).body['share'])
          self
        end

        def destroy
          requires :id
          service.delete_share(id)
          true
        end

        def ready?
          status == 'available'
        end

        def extend(size)
          requires :id
          service.extend_share(id, size)
          true
        end

        def shrink(size)
          requires :id
          service.shrink_share(id, size)
          true
        end

        def grant_access(access_to, access_type, access_level)
          requires :id
          service.grant_share_access(id, access_to, access_type, access_level)
          true
        end

        def revoke_access(access_id)
          requires :id
          service.revoke_share_access(id, access_id)
          true
        end

        def access_rules
          service.share_access_rules(:share => self)
        end
        
        def export_locations
          service.share_export_locations(:share => self)
        end
      end
    end
  end
end

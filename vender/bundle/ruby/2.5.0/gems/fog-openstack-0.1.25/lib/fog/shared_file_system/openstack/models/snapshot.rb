require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class Snapshot < Fog::OpenStack::Model
        identity :id

        attribute :share_id
        attribute :status
        attribute :name
        attribute :description
        attribute :share_proto
        attribute :share_size
        attribute :size
        attribute :provider_location
        attribute :links
        attribute :created_at

        def save
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          requires :share_id
          merge_attributes(service.create_snapshot(share_id, attributes).body['snapshot'])
          true
        end

        def update(options = nil)
          requires :id
          merge_attributes(service.update_snapshot(id, options || attributes).body['snapshot'])
          self
        end

        def destroy
          requires :id
          service.delete_snapshot(id)
          true
        end

        def ready?
          status == 'available'
        end
      end
    end
  end
end

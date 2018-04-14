require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class Snapshot < Fog::OpenStack::Model
        def update(data)
          requires :id

          response = service.update_snapshot(id, data)
          merge_attributes(response.body['snapshot'])

          self
        end

        def destroy
          requires :id
          service.delete_snapshot(id)
          true
        end

        # Existing keys have values updated and new key-value pairs are created, but none are deleted
        def update_metadata(metadata)
          requires :id
          service.update_snapshot_metadata(id, metadata)
          true
        end

        # Delete one specific key-value pair by specifying the key name
        def delete_metadata(key_name)
          requires :id
          service.delete_snapshot_metadata(id, key_name)
          true
        end
      end
    end
  end
end

require 'fog/openstack/models/model'
require 'fog/compute/openstack/models/metadata'

module Fog
  module Compute
    class OpenStack
      class Snapshot < Fog::OpenStack::Model
        identity :id

        attribute :name,        :aliases => 'displayName'
        attribute :description, :aliases => 'displayDescription'
        attribute :volume_id,   :aliases => 'volumeId'
        attribute :created_at,  :aliases => 'createdAt'
        attribute :status
        attribute :size

        def save(force = false)
          requires :volume_id, :name, :description
          data = service.create_snapshot(volume_id, name, description, force)
          merge_attributes(data.body['snapshot'])
          true
        end

        def destroy
          requires :id
          service.delete_snapshot(id)
          true
        end
      end
    end
  end
end

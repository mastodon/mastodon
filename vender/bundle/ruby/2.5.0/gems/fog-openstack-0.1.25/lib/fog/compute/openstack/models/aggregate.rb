require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class Aggregate < Fog::OpenStack::Model
        identity :id

        attribute :availability_zone
        attribute :name
        attribute :metadata
        attribute :deleted
        attribute :deleted_at
        attribute :updated_at
        attribute :created_at

        # Detailed
        attribute :hosts

        def save
          requires :name
          identity ? update : create
        end

        def create
          requires :name
          merge_attributes(service.create_aggregate(name, attributes).body['aggregate'])
          self
        end

        def update
          requires :id
          merge_attributes(service.update_aggregate(id, attributes).body['aggregate'])
          self
        end

        def add_host(host_uuid)
          requires :id
          service.add_aggregate_host(id, host_uuid)
        end

        def remove_host(host_uuid)
          requires :id
          service.remove_aggregate_host(id, host_uuid)
        end

        def update_metadata(metadata)
          service.update_aggregate_metadata(id, metadata)
        end

        def destroy
          requires :id
          service.delete_aggregate(id)
          true
        end
      end
    end
  end
end

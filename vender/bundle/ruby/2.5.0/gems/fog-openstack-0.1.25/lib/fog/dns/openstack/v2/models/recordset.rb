require 'fog/openstack/models/model'

module Fog
  module DNS
    class OpenStack
      class V2
        class Recordset < Fog::OpenStack::Model
          identity :id

          attribute :name
          attribute :project_id
          attribute :status
          attribute :action
          attribute :zone_id
          attribute :zone_name
          attribute :type
          attribute :records
          attribute :version
          attribute :created_at
          attribute :links

          attribute :ttl
          attribute :description
          attribute :updated_at

          def save
            raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
            requires :zone_id, :name, :type, :records
            merge_attributes(service.create_recordset(zone_id, name, type, records, attributes).body)
            true
          end

          # overwritten because zone_id is needed for get
          def reload(options = {})
            requires :zone_id, :id
            merge_attributes(collection.get(zone_id, id, options).attributes)
            self
          end

          def update(options = nil)
            requires :zone_id, :id
            merge_attributes(service.update_recordset(zone_id, id, options || attributes).body)
            self
          end

          def destroy(options = {})
            requires :zone_id, :id
            service.delete_recordset(zone_id, id, options)
            true
          end
        end
      end
    end
  end
end

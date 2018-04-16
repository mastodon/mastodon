require 'fog/volume/openstack/models/snapshot'

module Fog
  module Volume
    class OpenStack
      class V2
        class Snapshot < Fog::Volume::OpenStack::Snapshot
          identity :id

          attribute :name
          attribute :status
          attribute :description
          attribute :metadata
          attribute :force
          attribute :size

          def save
            requires :name
            data = if id.nil?
                     service.create_snapshot(attributes[:volume_id], name, description, force)
                   else
                     service.update_snapshot(id, attributes.reject { |k, _v| k == :id })
                   end
            merge_attributes(data.body['snapshot'])
            true
          end

          def create
            requires :name

            # volume_id, name, description, force=false
            response = service.create_snapshot(attributes[:volume_id],
                                               attributes[:name],
                                               attributes[:description],
                                               attributes[:force])
            merge_attributes(response.body['snapshot'])

            self
          end
        end
      end
    end
  end
end

require 'fog/volume/openstack/models/snapshot'

module Fog
  module Volume
    class OpenStack
      class V1
        class Snapshot < Fog::Volume::OpenStack::Snapshot
          identity :id

          attribute :display_name
          attribute :status
          attribute :display_description
          attribute :metadata
          attribute :force
          attribute :size

          def save
            requires :display_name
            data = if id.nil?
                     service.create_snapshot(attributes[:volume_id], display_name, display_description, force)
                   else
                     service.update_snapshot(id, attributes.reject { |k, _v| k == :id })
                   end
            merge_attributes(data.body['snapshot'])
            true
          end

          def create
            requires :display_name

            # volume_id, name, description, force=false
            response = service.create_snapshot(attributes[:volume_id],
                                               attributes[:display_name],
                                               attributes[:display_description],
                                               attributes[:force])
            merge_attributes(response.body['snapshot'])

            self
          end
        end
      end
    end
  end
end

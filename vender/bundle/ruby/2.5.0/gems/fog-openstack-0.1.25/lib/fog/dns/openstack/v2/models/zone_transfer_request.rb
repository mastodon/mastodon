require 'fog/openstack/models/model'

module Fog
  module DNS
    class OpenStack
      class V2
        class ZoneTransferRequest < Fog::OpenStack::Model
          identity :id
          attribute :project_id
          attribute :description
          attribute :status
          attribute :zone_id
          attribute :zone_name
          attribute :key
          attribute :target_project_id
          attribute :created_at
          attribute :updated_at
          attribute :version

          def save
            if persisted?
              update(description: description, target_project_id: target_project_id)
            else
              merge_attributes(ervice.create_zone_transfer_request(zone_id, {
                :target_project_id => target_project_id,
                :description => description,
                :project_id => project_id
              }))
            end
            true
          end

          def update(options = nil)
            requires :id
            merge_attributes(ervice.update_zone_transfer_request(id,options[:description],{
              :target_project_id => options[:target_project_id]
            }))
            self
          end

          def destroy(options = {})
            requires :id
            service.delete_zone_transfer_request(id)
            true
          end
        end
      end
    end
  end
end

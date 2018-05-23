require 'fog/openstack/models/model'

module Fog
  module DNS
    class OpenStack
      class V2
        class Zone < Fog::OpenStack::Model
          identity :id

          attribute :name
          attribute :email
          attribute :pool_id
          attribute :project_id
          attribute :serial
          attribute :status
          attribute :action
          attribute :masters
          attribute :version
          attribute :links
          attribute :created_at
          attribute :transfered_at

          attribute :ttl
          attribute :description
          attribute :type
          attribute :updated_at

          def save
            raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
            requires :name, :email
            merge_attributes(service.create_zone(name, email, attributes).body)
            true
          end

          def update(options = nil)
            requires :id
            merge_attributes(service.update_zone(id, options || attributes).body)
            self
          end

          def destroy(options = {})
            requires :id
            service.delete_zone(id, options)
            true
          end
        end
      end
    end
  end
end

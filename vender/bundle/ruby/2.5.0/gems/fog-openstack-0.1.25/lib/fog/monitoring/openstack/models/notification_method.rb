require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class NotificationMethod < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :links
        attribute :type
        attribute :address
        attribute :period

        def create
          requires :name, :type, :address
          merge_attributes(
            service.create_notification_method(attributes).body
          )
        end

        def update(attr = nil)
          requires :name, :type, :address
          merge_attributes(
            service.put_notification_method(id, attr || attributes).body
          )
        end

        def patch(attr = nil)
          merge_attributes(
            service.patch_notification_method(id, attr || attributes).body
          )
        end

        def destroy
          requires :id
          service.delete_notification_method(id)
          true
        end

        def to_s
          name
        end
      end
    end
  end
end

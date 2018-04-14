require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class Alarm < Fog::OpenStack::Model
        identity :id

        attribute :links
        attribute :link
        attribute :alarm_definition
        attribute :metrics
        attribute :state
        attribute :lifecycle_state
        attribute :state_updated_timestamp
        attribute :updated_timestamp
        attribute :created_timestamp

        def update(attr = nil)
          requires :id
          merge_attributes(
            service.update_alarm(id, attr || attributes).body
          )
          self
        end

        def patch(attr = nil)
          requires :id
          merge_attributes(
            service.patch_alarm(id, attr || attributes).body
          )
          self
        end

        def destroy
          requires :id
          service.delete_alarm(id)
          true
        end

        def to_s
          name
        end
      end
    end
  end
end

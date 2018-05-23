require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class AlarmDefinition < Fog::OpenStack::Model
        identity :id

        attribute :links
        attribute :name
        attribute :description
        attribute :expression
        attribute :deterministic
        attribute :expression_data
        attribute :match_by
        attribute :severity
        attribute :actions_enabled
        attribute :alarm_actions
        attribute :ok_actions
        attribute :undetermined_actions

        def create
          requires :name, :expression
          merge_attributes(
            service.create_alarm_definition(attributes).body
          )
          self
        end

        def update(attr = nil)
          requires :name, :expression
          merge_attributes(
            service.update_alarm_definition(id, attr || attributes).body
          )
        end

        def patch(attr = nil)
          requires :id
          merge_attributes(
            service.patch_alarm_definition(id, attr || attributes).body
          )
          self
        end

        def destroy
          requires :id
          service.delete_alarm_definition(id)
          true
        end

        def to_s
          name
        end
      end
    end
  end
end

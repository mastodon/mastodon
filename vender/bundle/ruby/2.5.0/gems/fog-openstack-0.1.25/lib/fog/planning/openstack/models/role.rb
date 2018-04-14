require 'fog/openstack/models/model'

module Fog
  module Openstack
    class Planning
      class Role < Fog::OpenStack::Model
        identity :uuid

        attribute :description
        attribute :name
        attribute :uuid

        def add_to_plan(plan_uuid)
          service.add_role_to_plan(plan_uuid, uuid)
        end

        def remove_from_plan(plan_uuid)
          service.remove_role_from_plan(plan_uuid, uuid)
        end
      end
    end
  end
end

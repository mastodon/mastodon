require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class RbacPolicy < Fog::OpenStack::Model
        identity :id

        attribute :object_type
        attribute :tenant_id
        attribute :target_tenant
        attribute :action

        def create
          requires :object_type, :object_id, :target_tenant, :action
          merge_attributes(service.create_rbac_policy(attributes).body['rbac_policy'])
          self
        end

        def update
          requires :id, :target_tenant
          merge_attributes(service.update_rbac_policy(id, attributes).body['rbac_policy'])
          self
        end

        def destroy
          requires :id
          service.delete_rbac_policy(id)
          true
        end
      end
    end
  end
end

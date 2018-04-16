require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V2
        class Tenant < Fog::OpenStack::Model
          identity :id

          attribute :description
          attribute :enabled
          attribute :name

          def to_s
            name
          end

          def roles_for(user)
            service.roles(
              :tenant => self,
              :user   => user
            )
          end

          def users
            requires :id
            service.users(:tenant_id => id)
          end

          def destroy
            requires :id
            service.delete_tenant(id)
            true
          end

          def update(attr = nil)
            requires :id, :name
            merge_attributes(
              service.update_tenant(id, attr || attributes).body['tenant']
            )
            self
          end

          def create
            requires :name
            merge_attributes(
              service.create_tenant(attributes).body['tenant']
            )
            self
          end

          def grant_user_role(user_id, role_id)
            service.add_user_to_tenant(id, user_id, role_id)
          end

          def revoke_user_role(user_id, role_id)
            service.remove_user_from_tenant(id, user_id, role_id)
          end
        end # class Tenant
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog

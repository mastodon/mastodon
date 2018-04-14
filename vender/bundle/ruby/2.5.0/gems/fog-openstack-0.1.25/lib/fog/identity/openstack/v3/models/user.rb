require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class User < Fog::OpenStack::Model
          identity :id

          attribute :default_project_id
          attribute :description
          attribute :domain_id
          attribute :email
          attribute :enabled
          attribute :name
          attribute :links
          attribute :password

          def to_s
            name
          end

          def groups
            requires :id
            service.list_user_groups(id).body['groups']
          end

          def projects
            requires :id
            service.list_user_projects(id).body['projects']
          end

          def roles
            requires :id, :domain_id
            service.list_domain_user_roles(domain_id, id).body['roles']
          end

          def grant_role(role_id)
            requires :id, :domain_id
            service.grant_domain_user_role(domain_id, id, role_id)
          end

          def check_role(role_id)
            requires :id, :domain_id
            begin
              service.check_domain_user_role(domain_id, id, role_id)
            rescue Fog::Identity::OpenStack::NotFound
              return false
            end
            true
          end

          def revoke_role(role_id)
            requires :id, :domain_id
            service.revoke_domain_user_role(domain_id, id, role_id)
          end

          def destroy
            requires :id
            service.delete_user(id)
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
              service.update_user(id, attr || attributes).body['user']
            )
            self
          end

          def create
            merge_attributes(
              service.create_user(attributes).body['user']
            )
            self
          end
        end
      end
    end
  end
end

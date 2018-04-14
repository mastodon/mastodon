require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Project < Fog::OpenStack::Model
          identity :id

          attribute :domain_id
          attribute :description
          attribute :enabled
          attribute :name
          attribute :links
          attribute :parent_id
          attribute :subtree
          attribute :parents

          class << self
            attr_accessor :cache
          end

          @cache = {}

          def to_s
            name
          end

          def destroy
            clear_cache
            requires :id
            service.delete_project(id)
            true
          end

          def update(attr = nil)
            clear_cache
            requires :id
            merge_attributes(
              service.update_project(id, attr || attributes).body['project']
            )
            self
          end

          def create
            clear_cache
            merge_attributes(
              service.create_project(attributes).body['project']
            )
            self
          end

          def user_roles(user_id)
            requires :id
            service.list_project_user_roles(id, user_id).body['roles']
          end

          def grant_role_to_user(role_id, user_id)
            clear_cache
            requires :id
            service.grant_project_user_role(id, user_id, role_id)
          end

          def check_user_role(user_id, role_id)
            requires :id
            begin
              service.check_project_user_role(id, user_id, role_id)
            rescue Fog::Identity::OpenStack::NotFound
              return false
            end
            true
          end

          def revoke_role_from_user(role_id, user_id)
            clear_cache
            requires :id
            service.revoke_project_user_role(id, user_id, role_id)
          end

          def group_roles(group_id)
            requires :id
            service.list_project_group_roles(id, group_id).body['roles']
          end

          def grant_role_to_group(role_id, group_id)
            clear_cache
            requires :id
            service.grant_project_group_role(id, group_id, role_id)
          end

          def check_group_role(group_id, role_id)
            requires :id
            begin
              service.check_project_group_role(id, group_id, role_id)
            rescue Fog::Identity::OpenStack::NotFound
              return false
            end
            true
          end

          def revoke_role_from_group(role_id, group_id)
            clear_cache
            requires :id
            service.revoke_project_group_role(id, group_id, role_id)
          end

          private

          def clear_cache
            self.class.cache = {}
          end
        end
      end
    end
  end
end

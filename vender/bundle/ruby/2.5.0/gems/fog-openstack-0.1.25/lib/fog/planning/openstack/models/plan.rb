require 'fog/openstack/models/model'

module Fog
  module Openstack
    class Planning
      class Plan < Fog::OpenStack::Model
        MASTER_TEMPLATE_NAME = 'plan.yaml'.freeze
        ENVIRONMENT_NAME = 'environment.yaml'.freeze

        identity :uuid

        attribute :description
        attribute :name
        attribute :uuid
        attribute :created_at
        attribute :updated_at
        attribute :parameters

        def templates
          service.get_plan_templates(uuid).body
        end

        def master_template
          templates[MASTER_TEMPLATE_NAME]
        end

        def environment
          templates[ENVIRONMENT_NAME]
        end

        def provider_resource_templates
          templates.select do |key, _template|
            ![MASTER_TEMPLATE_NAME, ENVIRONMENT_NAME].include?(key)
          end
        end

        def patch(parameters)
          service.patch_plan(uuid, parameters[:parameters]).body
        end

        def add_role(role_uuid)
          service.add_role_to_plan(uuid, role_uuid)
        end

        def remove_role(role_uuid)
          service.remove_role_from_plan(uuid, role_uuid)
        end

        def destroy
          requires :uuid
          service.delete_plan(uuid)
          true
        end

        def create
          requires :name
          merge_attributes(service.create_plan(attributes).body)
          self
        end

        def update(parameters = nil)
          requires :uuid
          merge_attributes(service.patch_plan(uuid, parameters).body)
          self
        end
      end
    end
  end
end

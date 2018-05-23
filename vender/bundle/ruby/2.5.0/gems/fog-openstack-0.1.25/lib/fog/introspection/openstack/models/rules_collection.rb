require 'fog/openstack/models/collection'
require 'fog/introspection/openstack/models/rules'

module Fog
  module Introspection
    class OpenStack
      class RulesCollection < Fog::OpenStack::Collection
        model Fog::Introspection::OpenStack::Rules

        def all(_options = {})
          load_response(service.list_rules, 'rules')
        end

        def get(uuid)
          data = service.get_rules(uuid).body
          new(data)
        rescue Fog::Introspection::OpenStack::NotFound
          nil
        end

        def destroy(uuid)
          rules = get(uuid)
          rules.destroy
        end

        def destroy_all
          service.delete_rules_all
        end
      end
    end
  end
end

require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/rbac_policy'

module Fog
  module Network
    class OpenStack
      class RbacPolicies < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::RbacPolicy

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_rbac_policies(filters), 'rbac_policies')
        end

        def get(rbac_policy_id)
          if rbac_policy = service.get_rbac_policy(rbac_policy_id).body['rbac_policy']
            new(rbac_policy)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
        alias find_by_id get
      end
    end
  end
end

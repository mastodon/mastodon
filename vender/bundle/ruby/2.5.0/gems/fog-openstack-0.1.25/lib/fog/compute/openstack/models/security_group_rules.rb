require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/security_group_rule'

module Fog
  module Compute
    class OpenStack
      class SecurityGroupRules < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::SecurityGroupRule

        def get(security_group_rule_id)
          if security_group_rule_id
            body = service.get_security_group_rule(security_group_rule_id).body
            new(body['security_group_rule'])
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

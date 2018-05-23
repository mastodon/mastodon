require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class SecurityGroup < Fog::OpenStack::Model
        identity  :id

        attribute :name
        attribute :description
        attribute :security_group_rules, :aliases => "rules"
        attribute :tenant_id

        def security_group_rules
          Fog::Compute::OpenStack::SecurityGroupRules.new(:service => service).load(attributes[:security_group_rules])
        end

        def rules
          Fog::Logger.deprecation('#rules is deprecated. Use #security_group_rules instead')
          attributes[:security_group_rules]
        end

        # no one should be calling this because it doesn't do anything
        # useful but we deprecated the rules attribute and need to maintain the API
        def rules=(new_rules)
          Fog::Logger.deprecation('#rules= is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRules collection to create new rules.')
          attributes[:security_group_rules] = new_rules
        end

        def save
          requires :name, :description
          data = service.create_security_group(name, description)
          merge_attributes(data.body['security_group'])
          true
        end

        def destroy
          requires :id
          service.delete_security_group(id)
          true
        end

        def create_security_group_rule(min, max, ip_protocol = "tcp", cidr = "0.0.0.0/0", group_id = nil)
          Fog::Logger.deprecation('#create_security_group_rule is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRules collection to create new rules.')
          requires :id
          service.create_security_group_rule(id, ip_protocol, min, max, cidr, group_id)
        end

        def delete_security_group_rule(rule_id)
          Fog::Logger.deprecation('#create_security_group_rule is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRule objects to destroy rules.')
          service.delete_security_group_rule(rule_id)
          true
        end
      end
    end
  end
end

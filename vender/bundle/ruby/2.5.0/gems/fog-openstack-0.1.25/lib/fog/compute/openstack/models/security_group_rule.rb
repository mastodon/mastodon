require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class SecurityGroupRule < Fog::OpenStack::Model
        identity :id

        attribute :from_port
        attribute :group
        attribute :ip_protocol
        attribute :to_port
        attribute :parent_group_id
        attribute :ip_range

        def save
          requires :ip_protocol, :from_port, :to_port, :parent_group_id
          cidr = ip_range && ip_range["cidr"]
          if rule = service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group).data[:body]
            merge_attributes(rule["security_group_rule"])
          end
        end

        def destroy
          requires :id
          service.delete_security_group_rule(id)
          true
        end
      end
    end
  end
end

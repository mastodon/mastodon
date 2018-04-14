module Fog
  module Network
    class OpenStack
      class Real
        # Delete a security group rule
        #
        # ==== Parameters
        # * 'security_group_rule_id'<~String> - UUID of the security group rule to delete
        def delete_security_group_rule(security_group_rule_id)
          request(
            :expects => 204,
            :method  => "DELETE",
            :path    => "security-group-rules/#{security_group_rule_id}"
          )
        end
      end

      class Mock
        def delete_security_group_rule(security_group_rule_id)
          response = Excon::Response.new
          if data[:security_group_rules][security_group_rule_id]
            data[:security_group_rules].delete(security_group_rule_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

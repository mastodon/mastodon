module Fog
  module Network
    class OpenStack
      class Real
        # Get details about a security group rule
        #
        # ==== Parameters
        # * 'security_group_rule_id'<~String> - UUID of the security group rule
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * 'security_group_rule'<~Hash>:
        #     * 'id'<~String> - UUID of the security group rule
        #     * 'direction'<~String> - Direction of traffic, must be in ['ingress', 'egress']
        #     * 'port_range_min'<~Integer> - Start port for rule i.e. 22 (or -1 for ICMP wildcard)
        #     * 'port_range_max'<~Integer> - End port for rule i.e. 22 (or -1 for ICMP wildcard)
        #     * 'protocol'<~String> - IP protocol for rule, must be in ['tcp', 'udp', 'icmp']
        #     * 'ethertype'<~String> - Type of ethernet support, must be in ['IPv4', 'IPv6']
        #     * 'security_group_id'<~String> - UUID of the parent security group
        #     * 'remote_group_id'<~String> - UUID of the remote security group
        #     * 'remote_ip_prefix'<~String> - IP cidr range address i.e. '0.0.0.0/0'
        #     * 'tenant_id'<~String> - Tenant id that owns the security group rule
        def get_security_group_rule(security_group_rule_id)
          request(
            :expects => 200,
            :method  => "GET",
            :path    => "security-group-rules/#{security_group_rule_id}"
          )
        end
      end

      class Mock
        def get_security_group_rule(security_group_rule_id)
          response = Excon::Response.new
          if sec_group_rule = data[:security_group_rules][security_group_rule_id]
            response.status = 200
            response.body   = {"security_group_rule" => sec_group_rule}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

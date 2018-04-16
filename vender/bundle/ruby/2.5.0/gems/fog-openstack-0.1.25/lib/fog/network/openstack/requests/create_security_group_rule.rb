module Fog
  module Network
    class OpenStack
      class Real
        # Create a new security group rule
        #
        # ==== Parameters
        # * 'security_group_id'<~String> - UUID of the parent security group
        # * 'direction'<~String> - Direction of traffic, must be in ['ingress', 'egress']
        # * options<~Hash>:
        #   * 'port_range_min'<~Integer> - Start port for rule i.e. 22 (or -1 for ICMP wildcard)
        #   * 'port_range_max'<~Integer> - End port for rule i.e. 22 (or -1 for ICMP wildcard)
        #   * 'protocol'<~String> - IP protocol for rule, must be in ['tcp', 'udp', 'icmp']
        #   * 'ethertype'<~String> - Type of ethernet support, must be in ['IPv4', 'IPv6']
        #   * 'remote_group_id'<~String> - UUID of the remote security group
        #   * 'remote_ip_prefix'<~String> - IP cidr range address i.e. '0.0.0.0/0'
        #   * 'tenant_id'<~String> - TenantId different than the current user, that should own the security group. Only allowed if user has 'admin' role.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * 'security_group_rule'<~Hash>:
        #     * 'id'<~String> - UUID of the security group rule
        #     * 'direction'<~String> - Direction of traffic, must be in ['ingress', 'egress']
        #     * 'port_range_min'<~String> - Start port for rule i.e. 22 (or -1 for ICMP wildcard)
        #     * 'port_range_max'<~String> - End port for rule i.e. 22 (or -1 for ICMP wildcard)
        #     * 'protocol'<~String> - IP protocol for rule, must be in ['tcp', 'udp', 'icmp']
        #     * 'ethertype'<~String> - Type of ethernet support, must be in ['IPv4', 'IPv6']
        #     * 'security_group_id'<~String> - UUID of the parent security group
        #     * 'remote_group_id'<~String> - UUID of the source security group
        #     * 'remote_ip_prefix'<~String> - IP cidr range address i.e. '0.0.0.0/0'
        #     * 'tenant_id'<~String> - Tenant id that owns the security group rule
        def create_security_group_rule(security_group_id, direction, options = {})
          data            = {"security_group_rule" => {"security_group_id" => security_group_id, "direction" => direction}}
          desired_options = [
            :port_range_min,
            :port_range_max,
            :protocol,
            :ethertype,
            :remote_group_id,
            :remote_ip_prefix,
            :tenant_id
          ]
          selected_options = desired_options.select { |o| options[o] }
          selected_options.each { |key| data["security_group_rule"][key] = options[key] }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 201,
            :method  => "POST",
            :path    => "security-group-rules"
          )
        end
      end

      class Mock
        def create_security_group_rule(security_group_id, direction, options = {})
          response = Excon::Response.new
          data = {
            "id"                => Fog::UUID.uuid,
            "remote_group_id"   => options[:remote_group_id],
            "direction"         => direction,
            "remote_ip_prefix"  => options[:remote_ip_prefix],
            "protocol"          => options[:protocol],
            "ethertype"         => options[:ethertype] || "IPv4",
            "tenant_id"         => options[:tenant_id] || Fog::Mock.random_numbers(14).to_s,
            "port_range_max"    => options[:port_range_max],
            "port_range_min"    => options[:port_range_min],
            "security_group_id" => security_group_id
          }
          self.data[:security_group_rules][data["id"]] = data
          response.status = 201
          response.body   = {"security_group_rule" => data}
          response
        end
      end
    end
  end
end

module Fog
  module Network
    class OpenStack
      class Real
        # List all security group rules
        #
        # ==== Parameters
        # * options<~Hash>:
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * 'security_group_rules'<~Array>:
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
        def list_security_group_rules(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'security-group-rules',
            :query   => options
          )
        end
      end

      class Mock
        def list_security_group_rules(_options = {})
          response = Excon::Response.new

          sec_group_rules = []
          sec_group_rules = data[:security_group_rules].values unless data[:security_group_rules].nil?

          response.status = 200
          response.body = {'security_group_rules' => sec_group_rules}
          response
        end
      end
    end
  end
end

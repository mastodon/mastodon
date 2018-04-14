module Fog
  module Network
    class OpenStack
      class Real
        # Create a new security group
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'name'<~String> - Name of the security group
        #   * 'description'<~String> - Description of the security group
        #   * 'tenant_id'<~String> - TenantId different than the current user, that should own the security group. Only allowed if user has 'admin' role.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * 'security_groups'<~Array>:
        #     * 'id'<~String> - UUID of the security group
        #     * 'name'<~String> - Name of the security group
        #     * 'description'<~String> - Description of the security group
        #     * 'tenant_id'<~String> - Tenant id that owns the security group
        #     * 'security_group_rules'<~Array>: - Array of security group rules
        #       * 'id'<~String> - UUID of the security group rule
        #       * 'direction'<~String> - Direction of traffic, must be in ['ingress', 'egress']
        #       * 'port_range_min'<~Integer> - Start port for rule i.e. 22 (or -1 for ICMP wildcard)
        #       * 'port_range_max'<~Integer> - End port for rule i.e. 22 (or -1 for ICMP wildcard)
        #       * 'protocol'<~String> - IP protocol for rule, must be in ['tcp', 'udp', 'icmp']
        #       * 'ethertype'<~String> - Type of ethernet support, must be in ['IPv4', 'IPv6']
        #       * 'security_group_id'<~String> - UUID of the parent security group
        #       * 'remote_group_id'<~String> - UUID of the remote security group
        #       * 'remote_ip_prefix'<~String> - IP cidr range address i.e. '0.0.0.0/0'
        #       * 'tenant_id'<~String> - Tenant id that owns the security group rule
        def create_security_group(options = {})
          data              = {"security_group" => {}}
          desired_options   = [:name, :description, :tenant_id]
          selected_options  = desired_options.select { |o| options[o] }
          selected_options.each { |key| data["security_group"][key] = options[key] }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 201,
            :method  => "POST",
            :path    => "security-groups"
          )
        end
      end

      class Mock
        def create_security_group(options = {})
          # Spaces are NOT removed from name and description, as in case of compute sec groups
          tenant_id     = Fog::Mock.random_numbers(14).to_s
          sec_group_id  = Fog::UUID.uuid

          response = Excon::Response.new
          response.status = 201
          # by default every security group will come setup with an egress rule to "allow all out"
          data = {
            "security_group_rules" => [
              {"remote_group_id"   => nil,
               "direction"         => "egress",
               "remote_ip_prefix"  => nil,
               "protocol"          => nil,
               "ethertype"         => "IPv4",
               "tenant_id"         => tenant_id,
               "port_range_max"    => nil,
               "port_range_min"    => nil,
               "id"                => Fog::UUID.uuid,
               "security_group_id" => sec_group_id},
              {"remote_group_id"   => nil,
               "direction"         => "egress",
               "remote_ip_prefix"  => nil,
               "protocol"          => nil,
               "ethertype"         => "IPv6",
               "tenant_id"         => tenant_id,
               "port_range_max"    => nil,
               "port_range_min"    => nil,
               "id"                => Fog::UUID.uuid,
               "security_group_id" => sec_group_id}
            ],
            "id"                   => sec_group_id,
            "tenant_id"            => tenant_id,
            "name"                 => options[:name] || "",
            "description"          => options[:description] || ""
          }

          self.data[:security_groups][data["id"]] = data
          response.body = {"security_group" => data}
          response
        end
      end
    end
  end
end

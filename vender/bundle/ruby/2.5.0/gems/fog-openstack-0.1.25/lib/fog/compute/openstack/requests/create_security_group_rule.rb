module Fog
  module Compute
    class OpenStack
      class Real
        def create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group_id = nil)
          data = {
            'security_group_rule' => {
              'parent_group_id' => parent_group_id,
              'ip_protocol'     => ip_protocol,
              'from_port'       => from_port,
              'to_port'         => to_port,
              'cidr'            => cidr,
              'group_id'        => group_id
            }
          }

          request(
            :expects => 200,
            :method  => 'POST',
            :body    => Fog::JSON.encode(data),
            :path    => 'os-security-group-rules'
          )
        end
      end

      class Mock
        def create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group_id = nil)
          parent_group_id = parent_group_id.to_i
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            'X-Compute-Request-Id' => "req-#{Fog::Mock.random_hex(32)}",
            'Content-Type'         => 'application/json',
            'Content-Length'       => Fog::Mock.random_numbers(3).to_s,
            'Date'                 => Date.new
          }
          rule = {
            'id'              => Fog::Mock.random_numbers(2).to_i,
            'from_port'       => from_port,
            'group'           => group_id || {},
            'ip_protocol'     => ip_protocol,
            'to_port'         => to_port,
            'parent_group_id' => parent_group_id,
            'ip_range'        => {
              'cidr' => cidr
            }
          }
          data[:security_groups][parent_group_id.to_s]['rules'].push(rule)
          response.body = {
            'security_group_rule' => rule
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog

module Fog
  module Compute
    class OpenStack
      class Real
        def get_security_group_rule(security_group_rule_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "os-security-group-rules/#{security_group_rule_id}"
          )
        end
      end

      class Mock
        def get_security_group_rule(security_group_rule_id)
          security_group_rule = nil
          data[:security_groups].find { |_id, sg| security_group_rule = sg["rules"].find { |sgr| sgr["id"].to_s == security_group_rule_id.to_s } }
          response = Excon::Response.new
          if security_group_rule
            response.status = 200
            response.headers = {
              "X-Compute-Request-Id" => "req-63a90344-7c4d-42e2-936c-fd748bced1b3",
              "Content-Type"         => "application/json",
              "Content-Length"       => "167",
              "Date"                 => Date.new
            }
            response.body = {
              "security_group_rule" => security_group_rule
            }
          else
            raise Fog::Compute::OpenStack::NotFound, "Security group rule #{security_group_rule_id} does not exist"
          end
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog

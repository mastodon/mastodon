module Fog
  module Compute
    class OpenStack
      class Real
        def get_security_group(security_group_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "os-security-groups/#{security_group_id}"
          )
        end
      end

      class Mock
        def get_security_group(security_group_id)
          security_group = data[:security_groups][security_group_id.to_s]
          response = Excon::Response.new
          if security_group
            response.status = 200
            response.headers = {
              "X-Compute-Request-Id" => "req-63a90344-7c4d-42e2-936c-fd748bced1b3",
              "Content-Type"         => "application/json",
              "Content-Length"       => "167",
              "Date"                 => Date.new
            }
            response.body = {
              "security_group" => security_group
            }
          else
            raise Fog::Compute::OpenStack::NotFound, "Security group #{security_group_id} does not exist"
          end
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog

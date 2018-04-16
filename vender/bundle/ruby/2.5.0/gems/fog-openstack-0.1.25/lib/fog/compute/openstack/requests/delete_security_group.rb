module Fog
  module Compute
    class OpenStack
      class Real
        def delete_security_group(security_group_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "os-security-groups/#{security_group_id}"
          )
        end
      end

      class Mock
        def delete_security_group(security_group_id)
          data[:security_groups].delete security_group_id.to_s

          response = Excon::Response.new
          response.status = 202
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response.body = {}
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog

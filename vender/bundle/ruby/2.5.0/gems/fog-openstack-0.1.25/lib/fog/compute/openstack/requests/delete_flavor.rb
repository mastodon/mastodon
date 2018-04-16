module Fog
  module Compute
    class OpenStack
      class Real
        def delete_flavor(flavor_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "flavors/#{flavor_id}"
          )
        end
      end

      class Mock
        def delete_flavor(_flavor_id)
          response = Excon::Response.new
          response.status = 202
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog

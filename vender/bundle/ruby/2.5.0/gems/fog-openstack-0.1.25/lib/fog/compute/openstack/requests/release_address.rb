module Fog
  module Compute
    class OpenStack
      class Real
        def release_address(address_id)
          request(
            :expects => [200, 202],
            :method  => 'DELETE',
            :path    => "os-floating-ips/#{address_id}"
          )
        end
      end

      class Mock
        def release_address(_address_id)
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
    end
  end
end

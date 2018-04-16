module Fog
  module Compute
    class OpenStack
      class Real
        def disassociate_address(server_id, ip_address)
          body = {"removeFloatingIp" => {"address" => ip_address}}
          server_action(server_id, body)
        end
      end

      class Mock
        def disassociate_address(_server_id, _ip_address)
          response = Excon::Response.new
          response.status = 202
          response.headers = {
            "Content-Type"   => "text/html, charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response
        end
      end
    end
  end
end

module Fog
  module Compute
    class OpenStack
      class Real
        def associate_address(server_id, ip_address)
          body = {"addFloatingIp" => {"address" => ip_address}}
          server_action(server_id, body)
        end
      end

      class Mock
        def associate_address(server_id, ip_address)
          server = data[:servers][server_id]
          server["addresses"]['mocknet'] ||= []
          ip_hash = {"OS-EXT-IPS-MAC:mac_addr" => "fa:16:3e:85:47:40", "version" => 4, "addr" => ip_address, "OS-EXT-IPS:type" => "floating"}
          server["addresses"]['mocknet'] << ip_hash

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

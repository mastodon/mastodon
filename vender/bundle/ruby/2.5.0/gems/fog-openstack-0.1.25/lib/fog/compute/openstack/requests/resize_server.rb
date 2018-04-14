module Fog
  module Compute
    class OpenStack
      class Real
        def resize_server(server_id, flavor_ref)
          body = {'resize' => {'flavorRef' => flavor_ref}}
          server_action(server_id, body)
        end
      end

      class Mock
        def resize_server(_server_id, _flavor_ref)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

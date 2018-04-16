module Fog
  module Compute
    class OpenStack
      class Real
        def confirm_resize_server(server_id)
          body = {'confirmResize' => nil}
          server_action(server_id, body, 204)
        end
      end

      class Mock
        def confirm_resize_server(_server_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end

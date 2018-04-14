module Fog
  module Compute
    class OpenStack
      class Real
        # Stop the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be stopped.
        # === Returns
        # * success <~Boolean>
        def stop_server(server_id)
          body = {'os-stop' => nil}
          server_action(server_id, body).status == 202
        end # def stop_server
      end # class Real

      class Mock
        def stop_server(_server_id)
          true
        end # def stop_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

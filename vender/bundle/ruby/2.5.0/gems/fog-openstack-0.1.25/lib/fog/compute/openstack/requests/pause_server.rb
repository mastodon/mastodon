module Fog
  module Compute
    class OpenStack
      class Real
        # Pause the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to pause.
        # === Returns
        # * success <~Boolean>
        def pause_server(server_id)
          body = {'pause' => nil}
          server_action(server_id, body).status == 202
        end # def pause_server
      end # class Real

      class Mock
        def pause_server(_server_id)
          true
        end # def pause_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

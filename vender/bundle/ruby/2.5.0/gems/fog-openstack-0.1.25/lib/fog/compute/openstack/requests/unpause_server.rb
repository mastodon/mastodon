module Fog
  module Compute
    class OpenStack
      class Real
        # Unpause the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to unpause.
        # === Returns
        # * success <~Boolean>
        def unpause_server(server_id)
          body = {'unpause' => nil}
          server_action(server_id, body).status == 202
        end # def unpause_server
      end # class Real

      class Mock
        def unpause_server(_server_id)
          true
        end # def unpause_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

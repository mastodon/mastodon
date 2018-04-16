module Fog
  module Compute
    class OpenStack
      class Real
        # Rescue the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be rescued.
        # === Returns
        # * success <~Boolean>
        def rescue_server(server_id)
          body = {'rescue' => nil}
          server_action(server_id, body) == 202
        end # def rescue_server
      end # class Real

      class Mock
        def rescue_server(_server_id)
          true
        end # def rescue_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

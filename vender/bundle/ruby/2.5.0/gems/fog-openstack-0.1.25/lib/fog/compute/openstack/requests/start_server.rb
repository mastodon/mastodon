module Fog
  module Compute
    class OpenStack
      class Real
        # Start the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be started.
        # === Returns
        # * success <~Boolean>
        def start_server(server_id)
          body = {'os-start' => nil}
          server_action(server_id, body).status == 202
        end # def start_server
      end # class Real

      class Mock
        def start_server(_server_id)
          true
        end # def start_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

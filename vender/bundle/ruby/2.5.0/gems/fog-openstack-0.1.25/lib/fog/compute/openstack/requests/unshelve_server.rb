module Fog
  module Compute
    class OpenStack
      class Real
        # Unshelve the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be unshelved
        # === Returns
        # * success <~Boolean>
        def unshelve_server(server_id)
          body = {'unshelve' => nil}
          server_action(server_id, body).status == 202
        end # def unshelve_server
      end # class Real

      class Mock
        def unshelve_server(_server_id)
          true
        end # def unshelve_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

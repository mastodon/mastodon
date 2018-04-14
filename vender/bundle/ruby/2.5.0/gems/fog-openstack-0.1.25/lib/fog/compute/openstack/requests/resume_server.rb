module Fog
  module Compute
    class OpenStack
      class Real
        # Resume the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be resumed.
        # === Returns
        # * success <~Boolean>
        def resume_server(server_id)
          body = {'resume' => nil}
          server_action(server_id, body).status == 202
        end # def resume_server
      end # class Real

      class Mock
        def resume_server(_server_id)
          true
        end # def resume_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

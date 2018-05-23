module Fog
  module Compute
    class OpenStack
      class Real
        # Suspend the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to suspend.
        # === Returns
        # * success <~Boolean>
        def suspend_server(server_id)
          body = {'suspend' => nil}
          server_action(server_id, body).status == 202
        end # def suspend_server
      end # class Real

      class Mock
        def suspend_server(_server_id)
          true
        end # def suspend_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

module Fog
  module Compute
    class OpenStack
      class Real
        # Shelve the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be shelved
        # === Returns
        # * success <~Boolean>
        def shelve_server(server_id)
          body = {'shelve' => nil}
          server_action(server_id, body).status == 202
        end # def shelve_server
      end # class Real

      class Mock
        def shelve_server(_server_id)
          true
        end # def shelve_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

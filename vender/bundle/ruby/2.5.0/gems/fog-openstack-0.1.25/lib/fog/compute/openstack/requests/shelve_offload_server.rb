module Fog
  module Compute
    class OpenStack
      class Real
        # Shelve Off load the server. Data and resource associations are deleted.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be shelve off loaded
        # === Returns
        # * success <~Boolean>
        def shelve_offload_server(server_id)
          body = {'shelveOffload' => nil}
          server_action(server_id, body).status == 202
        end # def shelve_off_load_server
      end # class Real

      class Mock
        def shelve_offload_server(_server_id)
          true
        end # def shelve_off_load_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog

module Fog
  module Compute
    class OpenStack
      class Real
        # Retrieve server diagnostics.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to retrieve diagnostics.
        # === Returns
        # * actions <~Array>
        def server_diagnostics(server_id)
          request(
            :method => 'GET',
            :path   => "servers/#{server_id}/diagnostics"
          )
        end # def server_diagnostics
      end # class Real

      class Mock
        def server_diagnostics(server_id)
        end # def server_diagnostics
      end # class Real
    end # class OpenStack
  end # module Compute
end # module Fog

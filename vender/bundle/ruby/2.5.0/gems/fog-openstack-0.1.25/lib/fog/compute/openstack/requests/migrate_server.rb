module Fog
  module Compute
    class OpenStack
      class Real
        def migrate_server(server_id)
          body = {'migrate' => nil}
          server_action(server_id, body)
        end
      end

      class Mock
        def migrate_server(_server_id)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

module Fog
  module Compute
    class OpenStack
      class Real
        def revert_resize_server(server_id)
          body = {'revertResize' => nil}
          server_action(server_id, body)
        end
      end

      class Mock
        def revert_resize_server(server_id)
          response = Excon::Response.new
          response.status = 202

          data[:servers][server_id]['flavorId'] = data[:servers][server_id]['old_flavorId']
          data[:servers][server_id].delete('old_flavorId')
          data[:last_modified][:servers][server_id] = Time.now
          data[:servers][server_id]['status'] = 'ACTIVE'

          response
        end
      end
    end
  end
end

module Fog
  module Compute
    class OpenStack
      class Real
        def reset_server_state(server_id, status)
          body = {'os-resetState' => {'state' => status}}
          server_action(server_id, body, 202)
        end
      end

      class Mock
        def reset_server_state(server_id, status)
          response = get_server_details(server_id)
          response.body['server']['status'] = status.upcase
          response
        end
      end
    end
  end
end

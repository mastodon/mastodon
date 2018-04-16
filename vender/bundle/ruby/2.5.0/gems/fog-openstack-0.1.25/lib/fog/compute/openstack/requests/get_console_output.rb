module Fog
  module Compute
    class OpenStack
      class Real
        def get_console_output(server_id, log_length)
          body = {
            'os-getConsoleOutput' => {
              'length' => log_length
            }
          }
          server_action(server_id, body)
        end
      end

      class Mock
        def get_console_output(_server_id, _log_length)
          response = Excon::Response.new
          response.status = 200
          response
        end
      end
    end
  end
end

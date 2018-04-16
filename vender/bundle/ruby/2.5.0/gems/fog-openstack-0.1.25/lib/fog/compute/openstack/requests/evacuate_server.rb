module Fog
  module Compute
    class OpenStack
      class Real
        def evacuate_server(server_id, host = nil, on_shared_storage = nil, admin_password = nil)
          evacuate                    = {}
          evacuate['host']            = host if host
          evacuate['onSharedStorage'] = on_shared_storage if on_shared_storage
          evacuate['adminPass']       = admin_password if admin_password
          body                        = {
            'evacuate' => evacuate
          }
          server_action(server_id, body)
        end
      end

      class Mock
        def evacuate_server(_server_id, _host, _on_shared_storage, _admin_password = nil)
          response        = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

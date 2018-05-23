module Fog
  module Compute
    class OpenStack
      class Real
        def rebuild_server(server_id, image_ref, name, admin_pass = nil, metadata = nil, personality = nil)
          body = {'rebuild' => {
            'imageRef' => image_ref,
            'name'     => name
          }}
          body['rebuild']['adminPass'] = admin_pass if admin_pass
          body['rebuild']['metadata'] = metadata if metadata
          if personality
            body['rebuild']['personality'] = []
            personality.each do |file|
              body['rebuild']['personality'] << {
                'contents' => Base64.encode64(file['contents']),
                'path'     => file['path']
              }
            end
          end
          server_action(server_id, body, 202)
        end
      end

      class Mock
        def rebuild_server(server_id, _image_ref, _name, _admin_pass = nil, _metadata = nil, _personality = nil)
          response = get_server_details(server_id)
          response.body['server']['status'] = "REBUILD"
          response
        end
      end
    end
  end
end

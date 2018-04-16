module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def grant_share_access(share_id, access_to = '0.0.0.0/0', access_type = 'ip', access_level = 'rw')
          action = {
            "#{action_prefix}allow_access" => {
              'access_to'    => access_to,
              'access_type'  => access_type,
              'access_level' => access_level
            }
          }
          share_action(share_id, action, 200)
        end
      end

      class Mock
        def grant_share_access(share_id, access_to, access_type, access_level)
          response = Excon::Response.new
          response.status = 200

          access                = data[:access_rules].first
          access[:share_id]     = share_id
          access[:access_level] = access_level
          access[:access_type]  = access_type
          access[:access_to]    = access_to

          response.body = {'access' => access}
          response
        end
      end
    end
  end
end

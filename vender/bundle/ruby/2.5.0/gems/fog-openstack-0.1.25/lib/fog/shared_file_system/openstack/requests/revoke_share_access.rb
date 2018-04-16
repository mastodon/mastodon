module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def revoke_share_access(share_id, access_id)
          action = {
            "#{action_prefix}deny_access" => {
              'access_id' => access_id
            }
          }
          share_action(share_id, action)
        end
      end

      class Mock
        def revoke_share_access(_share_id, _access_id)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

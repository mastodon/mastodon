module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def shrink_share(share_id, new_size)
          action = {
            "#{action_prefix}shrink" => {
              'new_size' => new_size
            }
          }
          share_action(share_id, action)
        end
      end

      class Mock
        def shrink_share(_share_id, _new_size)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_share_access_rules(share_id)
          action = {
            "#{action_prefix}access_list" => nil
          }
          share_action(share_id, action, 200)
        end
      end

      class Mock
        def list_share_access_rules(share_id)
          response = Excon::Response.new
          response.status = 200

          rules = data[:access_rules]
          rules.each do |rule|
            rule[:share_id] = share_id
          end

          response.body = {'access_list' => rules}
          response
        end
      end
    end
  end
end

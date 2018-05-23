module Fog
  module Compute
    class OpenStack
      class Real
        def remove_security_group(server_id, group_name)
          body = {'removeSecurityGroup' => {"name" => group_name}}
          server_action(server_id, body)
        end
      end

      class Mock
        def remove_security_group(_server_id, _group_name)
          response = Excon::Response.new
          response.status = 200
          response
        end
      end
    end
  end
end

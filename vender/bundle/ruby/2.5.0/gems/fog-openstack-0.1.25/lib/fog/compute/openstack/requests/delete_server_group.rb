module Fog
  module Compute
    class OpenStack
      class Real
        def delete_server_group(group_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "os-server-groups/#{group_id}"
          )
        end
      end

      class Mock
        def delete_server_group(group_id)
          response = Excon::Response.new
          response.status = data[:server_groups].delete(group_id) ? 204 : 404
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response
        end
      end
    end
  end
end

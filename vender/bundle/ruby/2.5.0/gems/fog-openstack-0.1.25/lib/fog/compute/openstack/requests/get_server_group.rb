module Fog
  module Compute
    class OpenStack
      class Real
        def get_server_group(group_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/os-server-groups/#{group_id}"
          )
        end
      end

      class Mock
        def get_server_group(group_id)
          grp = data[:server_groups][group_id]
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response.body = {'server_group' => {
            'id'         => group_id,
            'name'       => grp[:name],
            'policies'   => grp[:policies],
            'members'    => grp[:members],
            'metadata'   => {},
            'project_id' => 'test-project',
            'user_id'    => 'test-user'
          }}
          response
        end
      end
    end
  end
end

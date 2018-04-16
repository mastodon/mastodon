module Fog
  module Compute
    class OpenStack
      class Real
        def list_server_groups(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-server-groups',
            :query   => options
          )
        end
      end

      class Mock
        def list_server_groups(_options = {})
          groups = data[:server_groups].map do |id, group|
            group.merge('id' => id, 'project_id' => 'test-project', 'user_id' => 'test-user')
          end
          Excon::Response.new(
            :body   => {'server_groups' => groups},
            :status => 200
          )
        end
      end
    end
  end
end

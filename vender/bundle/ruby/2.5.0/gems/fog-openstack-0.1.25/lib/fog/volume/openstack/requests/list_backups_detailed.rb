module Fog
  module Volume
    class OpenStack
      module Real
        def list_backups_detailed(options = {})
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => 'backups/detail',
            :query    => options
          )
        end
      end

      module Mock
        def list_backups_detailed(_options = {})
          response = Excon::Response.new
          response.status = 200
          data[:backups] ||= [
            {
              "id" => "1",
              "volume_id" => "2",
              "name" => "backup 1",
              "status" => "available",
              "size" => 1,
              "object_count" => 16,
              "container" => "testcontainer",
            },
            {
              "id" => "2",
              "volume_id" => "2",
              "name" => "backup 2",
              "status" => "available",
              "size" => 1,
              "object_count" => 16,
              "container" => "testcontainer",
            }
          ]
          response.body = { 'backups' => data[:backups] }
          response
        end
      end
    end
  end
end

module Fog
  module Volume
    class OpenStack
      module Real
        def get_backup_details(backup_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "backups/#{backup_id}"
          )
        end
      end

      module Mock
        def get_backup_details(_backup_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "backup" => {
              "id" => "1",
              "volume_id" => "2",
              "name" => "backup 1",
              "status" => "available",
              "size" => 1,
              "object_count" => 16,
              "container" => "testcontainer",
            }
          }
          response
        end
      end
    end
  end
end

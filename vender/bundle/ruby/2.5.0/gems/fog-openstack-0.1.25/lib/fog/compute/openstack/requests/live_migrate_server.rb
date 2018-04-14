module Fog
  module Compute
    class OpenStack
      class Real
        def live_migrate_server(server_id, host, block_migration, disk_over_commit)
          body = {
            'os-migrateLive' => {
              'host'             => host,
              'block_migration'  => block_migration,
              'disk_over_commit' => disk_over_commit,
            }
          }
          server_action(server_id, body)
        end
      end

      class Mock
        def live_migrate_server(_server_id, _host, _block_migration, _disk_over_commit)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

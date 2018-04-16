module Fog
  module Volume
    class OpenStack
      module Real
        def delete_backup(backup_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "backups/#{backup_id}"
          )
        end
      end

      module Mock
        def delete_backup(_backup_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end

module Fog
  module Volume
    class OpenStack
      module Real
        def delete_snapshot(snapshot_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "snapshots/#{snapshot_id}"
          )
        end
      end

      module Mock
        def delete_snapshot(_snapshot_id)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

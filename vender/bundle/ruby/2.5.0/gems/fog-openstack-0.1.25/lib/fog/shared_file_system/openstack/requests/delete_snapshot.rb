module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def delete_snapshot(id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "snapshots/#{id}"
          )
        end
      end

      class Mock
        def delete_snapshot(id)
          response = Excon::Response.new
          response.status = 202

          snapshot                  = data[:snapshot_updated] || data[:snapshots_detail].first.dup
          snapshot['id']            = id
          snapshot['status']        = 'deleting'
          snapshot['links']['self'] = "https://127.0.0.1:8786/v2/snapshots/#{id}"

          response.body = {'snapshot' => snapshot}
          response
        end
      end
    end
  end
end

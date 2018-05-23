module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_snapshot(id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "snapshots/#{id}"
          )
        end
      end

      class Mock
        def get_snapshot(id)
          response = Excon::Response.new
          response.status = 200
          snapshot = data[:snapshot_updated] || data[:snapshots_detail].first
          snapshot['id'] = id
          response.body = snapshot
          response
        end
      end
    end
  end
end

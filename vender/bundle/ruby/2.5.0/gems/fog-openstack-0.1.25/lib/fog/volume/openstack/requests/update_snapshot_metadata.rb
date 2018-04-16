module Fog
  module Volume
    class OpenStack
      module Real
        def update_snapshot_metadata(snapshot_id, metadata = {})
          data = {
            'metadata' => metadata
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'POST',
            :path    => "snapshots/#{snapshot_id}/metadata"
          )
        end
      end
    end
  end
end

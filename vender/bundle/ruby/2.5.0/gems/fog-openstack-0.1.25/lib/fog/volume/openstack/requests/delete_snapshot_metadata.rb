module Fog
  module Volume
    class OpenStack
      module Real
        def delete_snapshot_metadata(snapshot_id, key_name)
          request(
            :expects => [200],
            :method  => 'DELETE',
            :path    => "snapshots/#{snapshot_id}/metadata/#{key_name}"
          )
        end
      end
    end
  end
end

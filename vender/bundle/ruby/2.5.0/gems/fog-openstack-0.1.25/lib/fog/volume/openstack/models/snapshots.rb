require 'fog/openstack/models/collection'

module Fog
  module Volume
    class OpenStack
      module Snapshots
        def all(options = {})
          load_response(service.list_snapshots_detailed(options), 'snapshots')
        end

        def summary(options = {})
          load_response(service.list_snapshots(options), 'snapshots')
        end

        def get(snapshots_id)
          snapshot = service.get_snapshot_details(snapshots_id).body['snapshot']
          if snapshot
            new(snapshot)
          end
        rescue Fog::Volume::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

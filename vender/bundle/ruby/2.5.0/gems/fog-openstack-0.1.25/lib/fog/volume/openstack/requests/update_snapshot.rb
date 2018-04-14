module Fog
  module Volume
    class OpenStack
      module Real
        def update_snapshot(snapshot_id, data = {})
          request(
            :body    => Fog::JSON.encode('snapshot' => data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "snapshots/#{snapshot_id}"
          )
        end
      end

      module Mock
        def update_snapshot(snapshot_id, options = {})
          unless snapshot_id
            raise ArgumentError, 'snapshot_id is required'
          end
          response = Excon::Response.new
          if snapshot = data[:snapshots][snapshot_id]
            response.status                 = 200
            snapshot['display_name']        = options['display_name'] if options['display_name']
            snapshot['display_description'] = options['display_description'] if options['display_description']
            snapshot['name']                = options['name'] if options['name']
            snapshot['description']         = options['description'] if options['description']
            snapshot['metadata']            = options['metadata'] if options['metadata']
            response.body                   = {'snapshot' => snapshot}
            response
          else
            raise Fog::HP::BlockStorageV2::NotFound
          end
        end
      end
    end
  end
end

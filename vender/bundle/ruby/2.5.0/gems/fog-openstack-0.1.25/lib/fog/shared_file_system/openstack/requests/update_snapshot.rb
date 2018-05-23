module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def update_snapshot(id, options = {})
          request(
            :body    => Fog::JSON.encode('snapshot' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "snapshots/#{id}"
          )
        end
      end

      class Mock
        def update_snapshot(id, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          data[:snapshot_updated]       = data[:snapshots_detail].first.merge(options)
          data[:snapshot_updated]['id'] = id

          response = Excon::Response.new
          response.status = 200
          response.body = {'snapshot' => data[:snapshot_updated]}
          response
        end
      end
    end
  end
end

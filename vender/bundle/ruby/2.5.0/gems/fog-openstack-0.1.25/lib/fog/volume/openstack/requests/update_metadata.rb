module Fog
  module Volume
    class OpenStack
      module Real
        def update_metadata(volume_id, metadata = {})
          data = {
            'metadata' => metadata
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200,202],
            :method  => 'POST',
            :path    => "volumes/#{volume_id}/metadata"
          )
        end
      end
    end
  end
end

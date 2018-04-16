module Fog
  module Volume
    class OpenStack
      module Real
        def delete_metadata(volume_id, key_name)
          request(
            :expects => [200],
            :method  => 'DELETE',
            :path    => "volumes/#{volume_id}/metadata/#{key_name}"
          )
        end
      end
    end
  end
end

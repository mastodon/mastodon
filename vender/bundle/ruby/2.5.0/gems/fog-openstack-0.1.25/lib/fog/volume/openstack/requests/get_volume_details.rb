module Fog
  module Volume
    class OpenStack
      module Real
        def get_volume_details(volume_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "volumes/#{volume_id}"
          )
        end
      end
    end
  end
end

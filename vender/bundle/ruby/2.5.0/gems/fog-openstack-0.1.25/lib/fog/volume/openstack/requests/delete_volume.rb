module Fog
  module Volume
    class OpenStack
      module Real
        def delete_volume(volume_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "volumes/#{volume_id}"
          )
        end
      end

      module Mock
        def delete_volume(_volume_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end

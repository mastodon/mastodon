module Fog
  module Volume
    class OpenStack
      module Real
        def extend_volume(volume_id, size)
          body = {'os-extend' => {'new_size' => size}}
          request(
            :expects => 202,
            :method  => 'POST',
            :path    => "volumes/#{volume_id}/action",
            :body    => Fog::JSON.encode(body)
          )
        end
      end

      module Mock
        def extend_volume(_volume_id, _size)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end

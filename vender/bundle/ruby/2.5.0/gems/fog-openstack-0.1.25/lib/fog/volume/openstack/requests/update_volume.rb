module Fog
  module Volume
    class OpenStack
      module Real
        def update_volume(volume_id, data = {})
          request(
            :body    => Fog::JSON.encode('volume' => data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "volumes/#{volume_id}"
          )
        end
      end

      module Mock
        def update_volume(volume_id, data = {})
          response        = Excon::Response.new
          response.status = 200
          response.body   = {'volume' => data.merge('id' => volume_id)}
          response
        end
      end
    end
  end
end

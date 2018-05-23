module Fog
  module Compute
    class OpenStack
      class Real
        def attach_volume(volume_id, server_id, device)
          data = {
            'volumeAttachment' => {
              'volumeId' => volume_id.to_s,
              'device'   => device
            }
          }
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "servers/%s/os-volume_attachments" % [server_id]
          )
        end
      end

      class Mock
        def attach_volume(volume_id, server_id, device)
          response = Excon::Response.new
          response.status = 200
          data = {
            'id'       => volume_id,
            'volumeId' => volume_id,
            'serverId' => server_id,
            'device'   => device
          }
          self.data[:volumes][volume_id]['attachments'] << data
          self.data[:volumes][volume_id]['status'] = 'in-use'
          response.body = {'volumeAttachment' => data}
          response
        end
      end
    end
  end
end

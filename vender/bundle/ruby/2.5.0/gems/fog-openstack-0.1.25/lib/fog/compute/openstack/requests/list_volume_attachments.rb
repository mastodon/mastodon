module Fog
  module Compute
    class OpenStack
      class Real
        def list_volume_attachments(server_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => format('servers/%s/os-volume_attachments', server_id)
          )
        end
      end

      class Mock
        def list_volume_attachments(server_id)
          Excon::Response.new(
            :body   => {
              :volumeAttachments => [{
                :device   => '/dev/vdd',
                :serverId => server_id,
                :id       => '24011ca7-9937-41e4-b19b-141307d1b656',
                :volumeId => '24011ca7-9937-41e4-b19b-141307d1b656'
              }]
            },
            :status => 200
          )
        end
      end
    end
  end
end

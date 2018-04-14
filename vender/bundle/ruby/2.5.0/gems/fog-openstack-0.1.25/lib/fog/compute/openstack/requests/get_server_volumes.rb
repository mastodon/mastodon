module Fog
  module Compute
    class OpenStack
      class Real
        def get_server_volumes(server_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/servers/#{server_id}/os-volume_attachments"
          )
        end
      end

      class Mock
        def get_server_volumes(server_id)
          response = Excon::Response.new
          response.status = 200
          data = self.data[:volumes].values.select do |vol|
            vol['attachments'].find { |attachment| attachment["serverId"] == server_id }
          end
          response.body = {'volumeAttachments' => data.map! { |vol| vol['attachments'] }.flatten(1)}
          response
        end
      end
    end
  end
end

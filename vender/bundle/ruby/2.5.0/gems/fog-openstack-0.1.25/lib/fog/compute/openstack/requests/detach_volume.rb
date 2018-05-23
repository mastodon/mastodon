module Fog
  module Compute
    class OpenStack
      class Real
        def detach_volume(server_id, attachment_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "servers/%s/os-volume_attachments/%s" % [server_id, attachment_id]
          )
        end
      end

      class Mock
        def detach_volume(server_id, attachment_id)
          response = Excon::Response.new
          if data[:volumes][attachment_id] &&
             data[:volumes][attachment_id]['attachments'].reject! { |attachment| attachment['serverId'] == server_id }
            data[:volumes][attachment_id]['status'] = 'available'
            response.status = 202
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end

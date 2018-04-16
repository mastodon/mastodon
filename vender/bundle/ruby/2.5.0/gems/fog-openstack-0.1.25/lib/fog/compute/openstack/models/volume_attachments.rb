require 'fog/core/collection'

module Fog
  module Compute
    class OpenStack
      class VolumeAttachments < Fog::Collection
        model Fog::Compute::OpenStack::VolumeAttachment

        def get(server_id)
          if server_id
            puts service.list_volume_attachments(server_id).body
            load(service.list_volume_attachments(server_id).body['volumeAttachments'])
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

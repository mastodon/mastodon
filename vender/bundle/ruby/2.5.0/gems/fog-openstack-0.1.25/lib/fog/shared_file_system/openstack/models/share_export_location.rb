require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class ShareExportLocation < Fog::OpenStack::Model
        identity :id
        
        attribute :share_instance_id
        attribute :path
        attribute :is_admin_only
        attribute :preferred
      end
    end
  end
end

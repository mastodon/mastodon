
require 'fog/openstack/models/model'

module Fog
  module KeyManager
    class OpenStack

      class ACL < Fog::OpenStack::Model
        identity :acl_ref

        attribute :uuid
        attribute :operation_type
        attribute :users, type: Array
        attribute :project_access
        attribute :secret_type
        attribute :created
        attribute :creator_id
        attribute :updated

      end
    end
  end
end

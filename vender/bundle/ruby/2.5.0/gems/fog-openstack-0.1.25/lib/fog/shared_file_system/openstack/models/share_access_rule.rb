require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class ShareAccessRule < Fog::OpenStack::Model
        attr_accessor :share

        identity :id

        attribute :access_level
        attribute :access_type
        attribute :access_to
        attribute :state

        def save
          requires :share, :access_level, :access_type, :access_to
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          merge_attributes(service.grant_share_access(@share.id, access_to, access_type, access_level).body['access'])
          true
        end

        def destroy
          requires :id, :share
          service.revoke_share_access(@share.id, id)
          true
        end

        def ready?
          state == 'active'
        end
      end
    end
  end
end

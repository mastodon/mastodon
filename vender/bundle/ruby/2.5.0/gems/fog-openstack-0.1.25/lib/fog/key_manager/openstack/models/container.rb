require 'fog/openstack/models/model'
require 'uri'

module Fog
  module KeyManager
    class OpenStack

      class Container < Fog::OpenStack::Model
        identity :container_ref

        attribute :uuid
        attribute :name
        attribute :type
        attribute :status
        attribute :creator_id

        attribute :secret_refs
        attribute :consumers

        attribute :created
        attribute :updated

        def uuid
          URI(self.container_ref).path.split('/').last
        rescue
          nil
        end

        def create
          merge_attributes(service.create_container(attributes).body)
          self
        end

        def destroy
          requires :container_ref
          service.delete_container(uuid)
          true
        end

      end

    end
  end
end
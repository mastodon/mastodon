require 'fog/openstack/models/model'
require 'uri'

module Fog
  module KeyManager
    class OpenStack

      class Secret < Fog::OpenStack::Model
        identity :secret_ref

        # create
        attribute :uuid
        attribute :name
        attribute :expiration
        attribute :bit_length, type: Integer
        attribute :algorithm
        attribute :mode
        attribute :secret_type

        attribute :content_types
        attribute :created
        attribute :creator_id
        attribute :status
        attribute :updated

        attribute :payload
        attribute :payload_content_type
        attribute :payload_content_encoding

        attribute :metadata

        def uuid
          URI(self.secret_ref).path.split('/').last
        rescue
          nil
        end

        def create
          merge_attributes(service.create_secret(attributes).body)
          self
        end

        def destroy
          requires :secret_ref
          service.delete_secret(uuid)
          true
        end

      end

    end
  end
end
require_relative 'base'

module Fog
  module ContainerInfra
    class OpenStack
      class Bay < Fog::ContainerInfra::OpenStack::Base
        identity :uuid

        attribute :api_address
        attribute :coe_version
        attribute :baymodel_id
        attribute :create_timeout
        attribute :created_at
        attribute :discovery_url
        attribute :master_addresses
        attribute :master_count
        attribute :name
        attribute :node_addresses
        attribute :node_count
        attribute :stack_id
        attribute :status
        attribute :status_reason
        attribute :updated_at

        def create
          requires :name, :baymodel_id
          merge_attributes(service.create_bay(attributes).body)
          self
        end

        def update
          requires :uuid, :name, :baymodel_id
          attrs = attributes.select{|k,_| allowed_update_attributes.include? k}
          attrs = convert_update_params(attrs)
          merge_attributes(service.update_bay(uuid, attrs).body)
          self
        end

        def destroy
          requires :uuid
          service.delete_bay(uuid)
          true
        end

        private

        def allowed_update_attributes
          [
            :node_count
          ]
        end

      end
    end
  end
end

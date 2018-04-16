require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class Flavor < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :ram
        attribute :disk
        attribute :vcpus
        attribute :links
        attribute :swap
        attribute :rxtx_factor
        attribute :metadata
        attribute :ephemeral, :aliases => 'OS-FLV-EXT-DATA:ephemeral'
        attribute :is_public, :aliases => 'os-flavor-access:is_public'
        attribute :disabled, :aliases => 'OS-FLV-DISABLED:disabled'

        def save
          requires :name, :ram, :vcpus, :disk
          attributes[:ephemeral] = ephemeral || 0
          attributes[:is_public] = is_public || false
          attributes[:disabled] = disabled || false
          attributes[:swap] = swap || 0
          attributes[:rxtx_factor] = rxtx_factor || 1.0
          merge_attributes(service.create_flavor(attributes).body['flavor'])
          self
        end

        def destroy
          requires :id
          service.delete_flavor(id)
          true
        end

        def metadata
          service.get_flavor_metadata(id).body['extra_specs']
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

        def create_metadata(metadata)
          service.create_flavor_metadata(id, metadata)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

        def update_metadata(key, value)
          service.update_flavor_metadata(id, key, value)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

        def delete_metadata(key)
          service.delete_flavor_metadata(id, key)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class Network < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :description
        attribute :neutron_net_id
        attribute :neutron_subnet_id
        attribute :nova_net_id
        attribute :network_type
        attribute :segmentation_id
        attribute :cidr
        attribute :ip_version
        attribute :project_id
        attribute :created_at
        attribute :updated_at

        def save
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          merge_attributes(service.create_share_network(attributes).body['share_network'])
          true
        end

        def update(options = nil)
          requires :id
          merge_attributes(service.update_share_network(id, options || attributes).body['share_network'])
          self
        end

        def destroy
          requires :id
          service.delete_share_network(id)
          true
        end
      end
    end
  end
end

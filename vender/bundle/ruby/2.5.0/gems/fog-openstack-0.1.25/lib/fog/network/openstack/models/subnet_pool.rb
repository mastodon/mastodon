require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class SubnetPool < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :prefixes
        attribute :description
        attribute :address_scope_id
        attribute :shared
        attribute :ip_version
        attribute :min_prefixlen
        attribute :max_prefixlen
        attribute :default_prefixlen
        attribute :is_default
        attribute :default_quota
        attribute :created_at
        attribute :updated_at
        attribute :tenant_id

        def create
          requires :name, :prefixes
          merge_attributes(service.create_subnet_pool(name,
                                                      prefixes,
                                                      attributes).body['subnetpool'])
          self
        end

        def update
          requires :id
          merge_attributes(service.update_subnet_pool(id,
                                                      attributes).body['subnetpool'])
          self
        end

        def destroy
          requires :id
          service.delete_subnet_pool(id)
          true
        end
      end
    end
  end
end

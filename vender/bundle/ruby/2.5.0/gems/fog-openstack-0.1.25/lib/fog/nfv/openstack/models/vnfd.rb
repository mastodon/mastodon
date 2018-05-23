require 'fog/openstack/models/model'

module Fog
  module NFV
    class OpenStack
      class Vnfd < Fog::OpenStack::Model
        identity :id

        attribute :service_types
        attribute :description
        attribute :tenant_id
        attribute :mgmt_driver
        attribute :infra_driver
        attribute :name
        attribute :vnf_attributes

        # Attributes for create
        attribute :vnfd
        attribute :auth

        def create(options = {})
          merge_attributes(service.create_vnfd(default_options.merge(options)).body['vnfd'])
          self
        end

        def update(_options = {})
          raise Fog::OpenStack::Errors::InterfaceNotImplemented, "Method 'update' is not supported"
        end

        def save(options = {})
          identity ? update(options) : create(options)
        end

        def destroy
          requires :id
          service.delete_vnfd(id)
          true
        end

        def default_options
          {
            :vnfd => vnfd,
            :auth => auth
          }
        end

        def vnf_attributes
          attributes['attributes']
        end
      end
    end
  end
end

require 'fog/openstack/models/model'

module Fog
  module NFV
    class OpenStack
      class Vnf < Fog::OpenStack::Model
        identity :id

        attribute :status
        attribute :name
        attribute :tenant_id
        attribute :instance_id
        attribute :mgmt_url
        attribute :description
        attribute :vnf_attributes

        # Attributes for create and update
        attribute :vnf
        attribute :auth

        def create(options = {})
          merge_attributes(service.create_vnf(default_options.merge(options)).body['vnf'])
          self
        end

        def update(options = {})
          merge_attributes(service.update_vnf(identity, default_options.merge(options)).body['vnf'])
          self
        end

        def save(options = {})
          identity ? update(options) : create(options)
        end

        def destroy
          requires :id
          service.delete_vnf(id)
          true
        end

        def default_options
          {
            :vnf  => vnf,
            :auth => auth
          }
        end

        def vnf_attributes
          attributes['attributes']
        end

        def ready?
          status == 'ACTIVE'
        end
      end
    end
  end
end

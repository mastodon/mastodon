require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class IpsecPolicy < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :description
        attribute :status
        attribute :admin_state_up
        attribute :tenant_id
        attribute :auth_algorithm
        attribute :encryption_algorithm
        attribute :pfs
        attribute :transform_protocol
        attribute :encapsulation_mode
        attribute :lifetime

        def create
          requires :name, :auth_algorithm, :encryption_algorithm,
                   :lifetime, :pfs, :transform_protocol,
                   :encapsulation_mode
          merge_attributes(service.create_ipsec_policy(attributes).body['ipsecpolicy'])
          self
        end

        def update
          requires :id, :name, :auth_algorithm, :encryption_algorithm,
                   :lifetime, :pfs, :transform_protocol,
                   :encapsulation_mode
          merge_attributes(service.update_ipsec_policy(id, attributes).body['ipsecpolicy'])
          self
        end

        def destroy
          requires :id
          service.delete_ipsec_policy(id)
          true
        end
      end
    end
  end
end

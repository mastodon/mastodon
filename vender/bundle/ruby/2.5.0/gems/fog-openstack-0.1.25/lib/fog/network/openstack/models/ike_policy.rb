require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class IkePolicy < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :description
        attribute :status
        attribute :admin_state_up
        attribute :tenant_id
        attribute :auth_algorithm
        attribute :encryption_algorithm
        attribute :pfs
        attribute :phase1_negotiation_mode
        attribute :lifetime
        attribute :ike_version

        def create
          requires :name, :auth_algorithm, :encryption_algorithm, :ike_version,
                   :lifetime, :pfs, :phase1_negotiation_mode
          merge_attributes(service.create_ike_policy(attributes).body['ikepolicy'])
          self
        end

        def update
          requires :id, :name, :auth_algorithm, :encryption_algorithm, :ike_version,
                   :lifetime, :pfs, :phase1_negotiation_mode
          merge_attributes(service.update_ike_policy(id, attributes).body['ikepolicy'])
          self
        end

        def destroy
          requires :id
          service.delete_ike_policy(id)
          true
        end
      end
    end
  end
end

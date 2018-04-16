require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class LbMember < Fog::OpenStack::Model
        identity :id

        attribute :pool_id
        attribute :address
        attribute :protocol_port
        attribute :weight
        attribute :status
        attribute :admin_state_up
        attribute :tenant_id

        def create
          requires :pool_id, :address, :protocol_port, :weight
          merge_attributes(service.create_lb_member(pool_id,
                                                    address,
                                                    protocol_port,
                                                    weight,
                                                    attributes).body['member'])
          self
        end

        def update
          requires :id, :pool_id, :address, :protocol_port, :weight
          merge_attributes(service.update_lb_member(id,
                                                    attributes).body['member'])
          self
        end

        def destroy
          requires :id
          service.delete_lb_member(id)
          true
        end
      end
    end
  end
end

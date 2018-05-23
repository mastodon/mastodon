require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class VpnService < Fog::OpenStack::Model
        identity :id

        attribute :subnet_id
        attribute :router_id
        attribute :name
        attribute :description
        attribute :status
        attribute :admin_state_up
        attribute :tenant_id
        attribute :external_v4_ip
        attribute :external_v6_ip

        def create
          requires :subnet_id, :router_id, :name, :admin_state_up
          merge_attributes(service.create_vpn_service(subnet_id,
                                                      router_id,
                                                      attributes).body['vpnservice'])
          self
        end

        def update
          requires :id, :subnet_id, :router_id, :name, :admin_state_up
          merge_attributes(service.update_vpn_service(id,
                                                      attributes).body['vpnservice'])
          self
        end

        def destroy
          requires :id
          service.delete_vpn_service(id)
          true
        end
      end
    end
  end
end

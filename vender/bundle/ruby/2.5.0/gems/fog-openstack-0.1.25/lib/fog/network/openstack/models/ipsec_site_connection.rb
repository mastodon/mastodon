require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class IpsecSiteConnection < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :description
        attribute :status
        attribute :admin_state_up
        attribute :tenant_id
        attribute :vpnservice_id
        attribute :ikepolicy_id
        attribute :ipsecpolicy_id
        attribute :peer_address
        attribute :peer_id
        attribute :peer_cidrs
        attribute :psk
        attribute :mtu
        attribute :dpd
        attribute :initiator

        def create
          requires :name, :vpnservice_id, :ikepolicy_id, :ipsecpolicy_id,
                   :peer_address, :peer_id, :peer_cidrs, :psk
          merge_attributes(service.create_ipsec_site_connection(vpnservice_id,
                                                                ikepolicy_id,
                                                                ipsecpolicy_id,
                                                                attributes).body['ipsec_site_connection'])
          self
        end

        def update
          requires :id, :name, :vpnservice_id, :ikepolicy_id, :ipsecpolicy_id,
                   :peer_address, :peer_id, :peer_cidrs, :psk
          merge_attributes(service.update_ipsec_site_connection(id,
                                                                attributes).body['ipsec_site_connection'])
          self
        end

        def destroy
          requires :id
          service.delete_ipsec_site_connection(id)
          true
        end
      end
    end
  end
end

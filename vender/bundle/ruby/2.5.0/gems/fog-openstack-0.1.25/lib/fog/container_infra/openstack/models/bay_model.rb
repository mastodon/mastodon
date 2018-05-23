require_relative 'base'

module Fog
  module ContainerInfra
    class OpenStack
      class BayModel < Fog::ContainerInfra::OpenStack::Base
        identity :uuid
        
        attribute :apiserver_port
        attribute :cluster_distro
        attribute :coe
        attribute :created_at
        attribute :dns_nameserver
        attribute :docker_storage_driver
        attribute :docker_volume_size
        attribute :external_network_id
        attribute :fixed_network
        attribute :fixed_subnet
        attribute :flavor_id
        attribute :floating_ip_enabled
        attribute :http_proxy
        attribute :https_proxy
        attribute :image_id
        attribute :insecure_registry
        attribute :keypair_id
        attribute :labels
        attribute :master_flavor_id
        attribute :master_lb_enabled
        attribute :name
        attribute :network_driver
        attribute :no_proxy
        attribute :public
        attribute :registry_enabled
        attribute :server_type
        attribute :tls_disabled
        attribute :updated_at
        attribute :volume_driver

        def create
          requires :name, :keypair_id,  :flavor_id, :image_id,
                   :external_network_id, :coe
          merge_attributes(service.create_bay_model(attributes).body)
          self
        end

        def update
          requires :uuid, :name, :keypair_id,  :flavor_id, :image_id,
                   :external_network_id, :coe
          attrs = convert_update_params(attributes)
          merge_attributes(service.update_bay_model(uuid, attrs).body)
          self
        end

        def destroy
          requires :uuid
          service.delete_bay_model(uuid)
          true
        end
      end
    end
  end
end

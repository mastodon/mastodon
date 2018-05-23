require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class Service < Fog::OpenStack::Model
        identity :id

        attribute :binary
        attribute :host
        attribute :state
        attribute :status
        attribute :updated_at
        attribute :zone

        # detailed
        attribute :disabled_reason

        def enable
          requires :binary, :host
          service.enable_service(host, binary)
        end

        def disable
          requires :binary, :host
          service.disable_service(host, binary)
        end

        def disable_and_log_reason
          requires :binary, :host, :disabled_reason
          service.disable_service_log_reason(host, binary, disabled_reason)
        end

        def destroy
          requires :id
          service.delete_service(id)
          true
        end
      end
    end
  end
end

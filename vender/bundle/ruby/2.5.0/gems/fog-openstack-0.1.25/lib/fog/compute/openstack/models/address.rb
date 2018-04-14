require 'fog/openstack/models/model'

module Fog
  module Compute
    class OpenStack
      class Address < Fog::OpenStack::Model
        identity  :id

        attribute :ip
        attribute :pool
        attribute :fixed_ip
        attribute :instance_id

        def initialize(attributes = {})
          # assign server first to prevent race condition with persisted?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          requires :id
          service.release_address(id)
          true
        end

        def server=(new_server)
          if new_server
            associate(new_server)
          else
            disassociate
          end
        end

        def save
          raise Fog::Errors::Error, 'Resaving an existing object may create a duplicate' if persisted?
          data = service.allocate_address(pool).body['floating_ip']
          new_attributes = data.reject { |key, _value| !['id', 'instance_id', 'ip', 'fixed_ip'].include?(key) }
          merge_attributes(new_attributes)
          if @server
            self.server = @server
          end
          true
        end

        private

        def associate(new_server)
          if persisted?
            @server = nil
            self.instance_id = new_server.id
            service.associate_address(instance_id, ip)
          else
            @server = new_server
          end
        end

        def disassociate
          @server = nil
          if persisted?
            service.disassociate_address(instance_id, ip)
          end
          self.instance_id = nil
        end
      end
    end
  end
end

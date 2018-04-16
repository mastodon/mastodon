require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Service < Fog::OpenStack::Model
          identity :id

          attribute :description
          attribute :type
          attribute :name
          attribute :links

          def to_s
            name
          end

          def destroy
            requires :id
            service.delete_service(id)
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
              service.update_service(id, attr || attributes).body['service']
            )
            self
          end

          def save
            requires :name
            identity ? update : create
          end

          def create
            merge_attributes(
              service.create_service(attributes).body['service']
            )
            self
          end
        end
      end
    end
  end
end

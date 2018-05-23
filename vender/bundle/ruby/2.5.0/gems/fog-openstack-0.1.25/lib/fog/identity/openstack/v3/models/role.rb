require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Role < Fog::OpenStack::Model
          identity :id

          attribute :name
          attribute :links

          def to_s
            name
          end

          def destroy
            requires :id
            service.delete_role(id)
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
              service.update_role(id, attr || attributes).body['role']
            )
            self
          end

          def create
            merge_attributes(
              service.create_role(attributes).body['role']
            )
            self
          end
        end
      end
    end
  end
end

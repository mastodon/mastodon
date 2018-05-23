require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Policy < Fog::OpenStack::Model
          identity :id

          attribute :type
          attribute :blob
          attribute :links

          def to_s
            name
          end

          def destroy
            requires :id
            service.delete_policy(id)
            true
          end

          def update(attr = nil)
            requires :id, :blob, :type
            merge_attributes(
              service.update_policy(id, attr || attributes).body['policy']
            )
            self
          end

          def create
            requires :blob, :type
            merge_attributes(
              service.create_policy(attributes).body['policy']
            )
            self
          end
        end
      end
    end
  end
end

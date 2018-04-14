require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Endpoint < Fog::OpenStack::Model
          identity :id

          attribute :description
          attribute :interface
          attribute :service_id
          attribute :name
          attribute :region
          attribute :url
          attribute :links

          def to_s
            name
          end

          def destroy
            requires :id
            service.delete_endpoint(id)
            true
          end

          def update(attr = nil)
            requires :id, :name
            merge_attributes(
              service.update_endpoint(id, attr || attributes).body['endpoint']
            )
            self
          end

          def create
            requires :name
            merge_attributes(
              service.create_endpoint(attributes).body['endpoint']
            )
            self
          end
        end
      end
    end
  end
end

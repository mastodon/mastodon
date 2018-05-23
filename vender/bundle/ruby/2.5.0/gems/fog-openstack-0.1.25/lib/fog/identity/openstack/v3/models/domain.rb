require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Domain < Fog::OpenStack::Model
          identity :id

          attribute :description
          attribute :enabled
          attribute :name
          attribute :links

          class << self
            attr_accessor :cache
          end

          @cache = {}

          def to_s
            name
          end

          def destroy
            clear_cache
            requires :id
            service.delete_domain(id)
            true
          end

          def update(attr = nil)
            clear_cache
            requires :id, :name
            merge_attributes(
              service.update_domain(id, attr || attributes).body['domain']
            )
            self
          end

          def create
            clear_cache
            requires :name
            merge_attributes(
              service.create_domain(attributes).body['domain']
            )
            self
          end

          private

          def clear_cache
            self.class.cache = {}
          end
        end
      end
    end
  end
end

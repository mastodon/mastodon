require 'fog/openstack/models/model'
require 'fog/openstack/models/meta_parent'

module Fog
  module Compute
    class OpenStack
      class Metadatum < Fog::OpenStack::Model
        include Fog::Compute::OpenStack::MetaParent

        identity :key
        attribute :value

        def destroy
          requires :identity
          service.delete_meta(collection_name, @parent.id, key)
          true
        end

        def save
          requires :identity, :value
          service.update_meta(collection_name, @parent.id, key, value)
          true
        end
      end
    end
  end
end

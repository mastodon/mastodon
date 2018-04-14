require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class VolumeType < Fog::OpenStack::Model
        attribute :extra_specs

        def create
          requires :name

          response = service.create_volume_type(attributes)
          merge_attributes(response.body['volume_type'])

          self
        end

        def update
          requires :id

          response = service.update_volume_type(id, attributes)
          merge_attributes(response.body['volume_type'])

          self
        end

        def destroy
          requires :id
          service.delete_volume_type(id)
          true
        end
      end
    end
  end
end

require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/image'

module Fog
  module Compute
    class OpenStack
      class Images < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Compute::OpenStack::Image

        attribute :server

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          data = service.list_images_detail(filters)
          images = load_response(data, 'images')
          if server
            replace(select { |image| image.server_id == server.id })
          end
          images
        end

        def get(image_id)
          data = service.get_image_details(image_id).body['image']
          new(data)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

require 'fog/openstack/models/collection'
require 'fog/image/openstack/v2/models/image'

module Fog
  module Image
    class OpenStack
      class V2
        class Images < Fog::OpenStack::Collection
          model Fog::Image::OpenStack::V2::Image

          def all(options = {})
            load_response(service.list_images(options), 'images')
          end

          def summary(options = {})
            load_response(service.list_images(options), 'images')
          end

          def find_by_id(id)
            new(service.get_image_by_id(id).body)
          rescue Fog::Image::OpenStack::NotFound
            nil
          end

          alias get find_by_id

          def public
            images = load(service.list_images.body['images'])
            images.delete_if { |image| image.is_public == false }
          end

          def private
            images = load(service.list_images.body['images'])
            images.delete_if(&:is_public)
          end

          def destroy(id)
            image = find_by_id(id)
            image.destroy
          end

          def method_missing(method_sym, *arguments, &block)
            if method_sym.to_s =~ /^find_by_(.*)$/
              load(service.list_images($1.to_sym => arguments.first).body['images'])
            else
              super
            end
          end

          def find_by_size_min(size)
            find_attribute(__method__, size)
          end

          def find_by_size_max(size)
            find_attribute(__method__, size)
          end

          def find_attribute(attribute, value)
            attribute = attribute.to_s.gsub("find_by_", "")
            load(service.list_images(attribute.to_sym => value).body['images'])
          end
        end
      end
    end
  end
end

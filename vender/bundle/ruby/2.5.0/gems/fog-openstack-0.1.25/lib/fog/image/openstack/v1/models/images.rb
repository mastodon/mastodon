require 'fog/openstack/models/collection'
require 'fog/image/openstack/v1/models/image'

module Fog
  module Image
    class OpenStack
      class V1
        class Images < Fog::OpenStack::Collection
          model Fog::Image::OpenStack::V1::Image

          def all(options = {})
            load_response(service.list_public_images_detailed(options), 'images')
          end

          def summary(options = {})
            load_response(service.list_public_images(options), 'images')
          end

          def details(options = {}, deprecated_query = nil)
            Fog::Logger.deprecation("Calling OpenStack[:glance].images.details will be removed, "\
                                    " call .images.all for detailed list.")
            load_response(service.list_public_images_detailed(options, deprecated_query), 'images')
          end

          def find_by_id(id)
            marker          = 'X-Image-Meta-'
            property_marker = 'X-Image-Meta-Property-'
            headers = service.get_image_by_id(id).headers.select { |h, _| h.start_with?(marker) }

            # partioning on the longer prefix, leaving X-Image-Meta
            # headers in the second returned hash.
            custom_properties, params = headers.partition do |k, _|
              k.start_with?(property_marker)
            end.map { |p| Hash[p] }

            params            = remove_prefix_and_convert_type(params, marker)
            custom_properties = remove_prefix_and_convert_type(custom_properties, property_marker)

            params['properties'] = custom_properties
            new(params)
          rescue Fog::Image::OpenStack::NotFound
            nil
          end
          alias get find_by_id

          def public
            images = load(service.list_public_images_detailed.body['images'])
            images.delete_if { |image| image.is_public == false }
          end

          def private
            images = load(service.list_public_images_detailed.body['images'])
            images.delete_if(&:is_public)
          end

          def destroy(id)
            image = find_by_id(id)
            image.destroy
          end

          def method_missing(method_sym, *arguments, &block)
            if method_sym.to_s =~ /^find_by_(.*)$/
              load(service.list_public_images_detailed($1, arguments.first).body['images'])
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
            load(service.list_public_images_detailed(attribute, value).body['images'])
          end

          private

          def convert_to_type(v)
            case v
            when /^\d+$/
              v.to_i
            when 'True'
              true
            when 'False'
              false
            when /^\d\d\d\d\-\d\d\-\d\dT/
              ::Time.parse(v)
            else
              v
            end
          end

          def remove_prefix_and_convert_type(hash, prefix)
            Hash[hash.map { |k, v| [k.gsub(prefix, '').downcase, convert_to_type(v)] }]
          end
        end
      end
    end
  end
end

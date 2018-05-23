require 'jsonapi/renderer/resources_processor'

module JSONAPI
  class Renderer
    # @api private
    class SimpleResourcesProcessor < ResourcesProcessor
      def process_resources
        [@primary, @included].each do |resources|
          resources.map! do |res|
            ri = [res.jsonapi_type, res.jsonapi_id]
            include_dir = @include_rels[ri]
            fields = @fields[res.jsonapi_type.to_sym]
            res.as_jsonapi(include: include_dir, fields: fields)
          end
        end
      end
    end
  end
end

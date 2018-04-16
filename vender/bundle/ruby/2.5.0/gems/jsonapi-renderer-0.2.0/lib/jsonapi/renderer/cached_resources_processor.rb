require 'jsonapi/renderer/resources_processor'

module JSONAPI
  class Renderer
    # @private
    class CachedResourcesProcessor < ResourcesProcessor
      class JSONString < String
        def to_json(*)
          self
        end
      end

      def initialize(cache)
        @cache = cache
      end

      def process_resources
        [@primary, @included].each do |resources|
          cache_hash = cache_key_map(resources)
          processed_resources = @cache.fetch_multi(cache_hash.keys) do |key|
            res, include, fields = cache_hash[key]
            json = res.as_jsonapi(include: include, fields: fields).to_json

            JSONString.new(json)
          end

          resources.replace(processed_resources.values)
        end
      end

      def cache_key_map(resources)
        resources.each_with_object({}) do |res, h|
          ri = [res.jsonapi_type, res.jsonapi_id]
          include_dir = @include_rels[ri]
          fields = @fields[ri.first.to_sym]
          h[res.jsonapi_cache_key(include: include_dir, fields: fields)] =
            [res, include_dir, fields]
        end
      end
    end
  end
end

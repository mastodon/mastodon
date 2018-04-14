require 'jsonapi/include_directive'
require 'jsonapi/renderer/simple_resources_processor'
require 'jsonapi/renderer/cached_resources_processor'

module JSONAPI
  class Renderer
    # @private
    class Document
      def initialize(params = {})
        @data    = params.fetch(:data,    :no_data)
        @errors  = params.fetch(:errors,  [])
        @meta    = params[:meta]
        @links   = params[:links] || {}
        @fields  = _symbolize_fields(params[:fields] || {})
        @jsonapi = params[:jsonapi]
        @include = JSONAPI::IncludeDirective.new(params[:include] || {})
        @relationship = params[:relationship]
        @cache = params[:cache]
      end

      def to_hash
        @hash ||= document_hash
      end
      alias to_h to_hash

      private

      # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      def document_hash
        {}.tap do |hash|
          if @relationship
            hash.merge!(relationship_hash)
          elsif @data != :no_data
            hash.merge!(data_hash)
          elsif @errors.any?
            hash.merge!(errors_hash)
          end
          hash[:links]   = @links   if @links.any?
          hash[:meta]    = @meta    unless @meta.nil?
          hash[:jsonapi] = @jsonapi unless @jsonapi.nil?
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      def data_hash
        primary, included =
          resources_processor.process(Array(@data), @include, @fields)
        {}.tap do |hash|
          hash[:data]     = @data.respond_to?(:to_ary) ? primary : primary[0]
          hash[:included] = included if included.any?
        end
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def relationship_hash
        rel_name = @relationship.to_sym
        data = @data.jsonapi_related([rel_name])[rel_name]
        included =
          if @include.key?(rel_name)
            resources_processor.process(data, @include[rel_name], @fields)
                               .flatten!
          else
            []
          end

        res = @data.as_jsonapi(fields: [rel_name], include: [rel_name])
        rel = res[:relationships][rel_name]
        @links = rel[:links].merge!(@links)
        @meta ||= rel[:meta]

        {}.tap do |hash|
          hash[:data]     = rel[:data]
          hash[:included] = included if included.any?
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def errors_hash
        {}.tap do |hash|
          hash[:errors] = @errors.flat_map(&:as_jsonapi)
        end
      end

      def resources_processor
        if @cache
          CachedResourcesProcessor.new(@cache)
        else
          SimpleResourcesProcessor.new
        end
      end

      def _symbolize_fields(fields)
        fields.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = v.map(&:to_sym)
        end
      end
    end
  end
end

module ActiveModel
  class Serializer
    class CollectionSerializer
      include Enumerable
      delegate :each, to: :@serializers

      attr_reader :object, :root

      def initialize(resources, options = {})
        @object                  = resources
        @options                 = options
        @root                    = options[:root]
        @serializers             = serializers_from_resources
      end

      def success?
        true
      end

      # @api private
      def serializable_hash(adapter_options, options, adapter_instance)
        include_directive = ActiveModel::Serializer.include_directive_from_options(adapter_options)
        adapter_options[:cached_attributes] ||= ActiveModel::Serializer.cache_read_multi(self, adapter_instance, include_directive)
        adapter_opts = adapter_options.merge(include_directive: include_directive)
        serializers.map do |serializer|
          serializer.serializable_hash(adapter_opts, options, adapter_instance)
        end
      end

      # TODO: unify naming of root, json_key, and _type.  Right now, a serializer's
      # json_key comes from the root option or the object's model name, by default.
      # But, if a dev defines a custom `json_key` method with an explicit value,
      # we have no simple way to know that it is safe to call that instance method.
      # (which is really a class property at this point, anyhow).
      # rubocop:disable Metrics/CyclomaticComplexity
      # Disabling cop since it's good to highlight the complexity of this method by
      # including all the logic right here.
      def json_key
        return root if root
        # 1. get from options[:serializer] for empty resource collection
        key = object.empty? &&
          (explicit_serializer_class = options[:serializer]) &&
          explicit_serializer_class._type
        # 2. get from first serializer instance in collection
        key ||= (serializer = serializers.first) && serializer.json_key
        # 3. get from collection name, if a named collection
        key ||= object.respond_to?(:name) ? object.name && object.name.underscore : nil
        # 4. key may be nil for empty collection and no serializer option
        key &&= key.pluralize
        # 5. fail if the key cannot be determined
        key || fail(ArgumentError, 'Cannot infer root key from collection type. Please
                 specify the root or each_serializer option, or render a JSON String')
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def paginated?
        ActiveModelSerializers.config.jsonapi_pagination_links_enabled &&
          object.respond_to?(:current_page) &&
          object.respond_to?(:total_pages) &&
          object.respond_to?(:size)
      end

      protected

      attr_reader :serializers, :options

      private

      def serializers_from_resources
        serializer_context_class = options.fetch(:serializer_context_class, ActiveModel::Serializer)
        object.map do |resource|
          serializer_from_resource(resource, serializer_context_class, options)
        end
      end

      def serializer_from_resource(resource, serializer_context_class, options)
        serializer_class = options.fetch(:serializer) do
          serializer_context_class.serializer_for(resource, namespace: options[:namespace])
        end

        if serializer_class.nil?
          ActiveModelSerializers.logger.debug "No serializer found for resource: #{resource.inspect}"
          throw :no_serializer
        else
          serializer_class.new(resource, options.except(:serializer))
        end
      end
    end
  end
end

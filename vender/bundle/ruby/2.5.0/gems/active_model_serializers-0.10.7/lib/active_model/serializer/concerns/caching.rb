module ActiveModel
  class Serializer
    UndefinedCacheKey = Class.new(StandardError)
    module Caching
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_cache         # @api private : the cache store
          serializer.class_attribute :_cache_key     # @api private : when present, is first item in cache_key.  Ignored if the serializable object defines #cache_key.
          serializer.class_attribute :_cache_only    # @api private : when fragment caching, whitelists fetch_attributes. Cannot combine with except
          serializer.class_attribute :_cache_except  # @api private : when fragment caching, blacklists fetch_attributes. Cannot combine with only
          serializer.class_attribute :_cache_options # @api private : used by CachedSerializer, passed to _cache.fetch
          #  _cache_options include:
          #    expires_in
          #    compress
          #    force
          #    race_condition_ttl
          #  Passed to ::_cache as
          #    serializer.cache_store.fetch(cache_key, @klass._cache_options)
          #  Passed as second argument to serializer.cache_store.fetch(cache_key, serializer_class._cache_options)
          serializer.class_attribute :_cache_digest_file_path # @api private : Derived at inheritance
        end
      end

      # Matches
      #  "c:/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
      #  AND
      #  "/c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
      #  AS
      #  c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb
      CALLER_FILE = /
        \A       # start of string
        .+       # file path (one or more characters)
        (?=      # stop previous match when
          :\d+     # a colon is followed by one or more digits
          :in      # followed by a colon followed by in
        )
      /x

      module ClassMethods
        def inherited(base)
          caller_line = caller[1]
          base._cache_digest_file_path = caller_line
          super
        end

        def _cache_digest
          return @_cache_digest if defined?(@_cache_digest)
          @_cache_digest = digest_caller_file(_cache_digest_file_path)
        end

        # Hashes contents of file for +_cache_digest+
        def digest_caller_file(caller_line)
          serializer_file_path = caller_line[CALLER_FILE]
          serializer_file_contents = IO.read(serializer_file_path)
          Digest::MD5.hexdigest(serializer_file_contents)
        rescue TypeError, Errno::ENOENT
          warn <<-EOF.strip_heredoc
            Cannot digest non-existent file: '#{caller_line}'.
            Please set `::_cache_digest` of the serializer
            if you'd like to cache it.
            EOF
          ''.freeze
        end

        def _skip_digest?
          _cache_options && _cache_options[:skip_digest]
        end

        # @api private
        # maps attribute value to explicit key name
        # @see Serializer::attribute
        # @see Serializer::fragmented_attributes
        def _attributes_keys
          _attributes_data
            .each_with_object({}) do |(key, attr), hash|
            next if key == attr.name
            hash[attr.name] = { key: key }
          end
        end

        def fragmented_attributes
          cached = _cache_only ? _cache_only : _attributes - _cache_except
          cached = cached.map! { |field| _attributes_keys.fetch(field, field) }
          non_cached = _attributes - cached
          non_cached = non_cached.map! { |field| _attributes_keys.fetch(field, field) }
          {
            cached: cached,
            non_cached: non_cached
          }
        end

        # Enables a serializer to be automatically cached
        #
        # Sets +::_cache+ object to <tt>ActionController::Base.cache_store</tt>
        #   when Rails.configuration.action_controller.perform_caching
        #
        # @param options [Hash] with valid keys:
        #   cache_store    : @see ::_cache
        #   key            : @see ::_cache_key
        #   only           : @see ::_cache_only
        #   except         : @see ::_cache_except
        #   skip_digest    : does not include digest in cache_key
        #   all else       : @see ::_cache_options
        #
        # @example
        #   class PostSerializer < ActiveModel::Serializer
        #     cache key: 'post', expires_in: 3.hours
        #     attributes :title, :body
        #
        #     has_many :comments
        #   end
        #
        # @todo require less code comments. See
        # https://github.com/rails-api/active_model_serializers/pull/1249#issuecomment-146567837
        def cache(options = {})
          self._cache =
            options.delete(:cache_store) ||
            ActiveModelSerializers.config.cache_store ||
            ActiveSupport::Cache.lookup_store(:null_store)
          self._cache_key = options.delete(:key)
          self._cache_only = options.delete(:only)
          self._cache_except = options.delete(:except)
          self._cache_options = options.empty? ? nil : options
        end

        # Value is from ActiveModelSerializers.config.perform_caching. Is used to
        # globally enable or disable all serializer caching, just like
        # Rails.configuration.action_controller.perform_caching, which is its
        # default value in a Rails application.
        # @return [true, false]
        # Memoizes value of config first time it is called with a non-nil value.
        # rubocop:disable Style/ClassVars
        def perform_caching
          return @@perform_caching if defined?(@@perform_caching) && !@@perform_caching.nil?
          @@perform_caching = ActiveModelSerializers.config.perform_caching
        end
        alias perform_caching? perform_caching
        # rubocop:enable Style/ClassVars

        # The canonical method for getting the cache store for the serializer.
        #
        # @return [nil] when _cache is not set (i.e. when `cache` has not been called)
        # @return [._cache] when _cache is not the NullStore
        # @return [ActiveModelSerializers.config.cache_store] when _cache is the NullStore.
        #   This is so we can use `cache` being called to mean the serializer should be cached
        #   even if ActiveModelSerializers.config.cache_store has not yet been set.
        #   That means that when _cache is the NullStore and ActiveModelSerializers.config.cache_store
        #   is configured, `cache_store` becomes `ActiveModelSerializers.config.cache_store`.
        # @return [nil] when _cache is the NullStore and ActiveModelSerializers.config.cache_store is nil.
        def cache_store
          return nil if _cache.nil?
          return _cache if _cache.class != ActiveSupport::Cache::NullStore
          if ActiveModelSerializers.config.cache_store
            self._cache = ActiveModelSerializers.config.cache_store
          else
            nil
          end
        end

        def cache_enabled?
          perform_caching? && cache_store && !_cache_only && !_cache_except
        end

        def fragment_cache_enabled?
          perform_caching? && cache_store &&
            (_cache_only && !_cache_except || !_cache_only && _cache_except)
        end

        # Read cache from cache_store
        # @return [Hash]
        # Used in CollectionSerializer to set :cached_attributes
        def cache_read_multi(collection_serializer, adapter_instance, include_directive)
          return {} if ActiveModelSerializers.config.cache_store.blank?

          keys = object_cache_keys(collection_serializer, adapter_instance, include_directive)

          return {} if keys.blank?

          ActiveModelSerializers.config.cache_store.read_multi(*keys)
        end

        # Find all cache_key for the collection_serializer
        # @param serializers [ActiveModel::Serializer::CollectionSerializer]
        # @param adapter_instance [ActiveModelSerializers::Adapter::Base]
        # @param include_directive [JSONAPI::IncludeDirective]
        # @return [Array] all cache_key of collection_serializer
        def object_cache_keys(collection_serializer, adapter_instance, include_directive)
          cache_keys = []

          collection_serializer.each do |serializer|
            cache_keys << object_cache_key(serializer, adapter_instance)

            serializer.associations(include_directive).each do |association|
              # TODO(BF): Process relationship without evaluating lazy_association
              association_serializer = association.lazy_association.serializer
              if association_serializer.respond_to?(:each)
                association_serializer.each do |sub_serializer|
                  cache_keys << object_cache_key(sub_serializer, adapter_instance)
                end
              else
                cache_keys << object_cache_key(association_serializer, adapter_instance)
              end
            end
          end

          cache_keys.compact.uniq
        end

        # @return [String, nil] the cache_key of the serializer or nil
        def object_cache_key(serializer, adapter_instance)
          return unless serializer.present? && serializer.object.present?

          (serializer.class.cache_enabled? || serializer.class.fragment_cache_enabled?) ? serializer.cache_key(adapter_instance) : nil
        end
      end

      ### INSTANCE METHODS
      def fetch_attributes(fields, cached_attributes, adapter_instance)
        key = cache_key(adapter_instance)
        cached_attributes.fetch(key) do
          fetch(adapter_instance, serializer_class._cache_options, key) do
            attributes(fields, true)
          end
        end
      end

      def fetch(adapter_instance, cache_options = serializer_class._cache_options, key = nil)
        if serializer_class.cache_store
          key ||= cache_key(adapter_instance)
          serializer_class.cache_store.fetch(key, cache_options) do
            yield
          end
        else
          yield
        end
      end

      # 1. Determine cached fields from serializer class options
      # 2. Get non_cached_fields and fetch cache_fields
      # 3. Merge the two hashes using adapter_instance#fragment_cache
      def fetch_attributes_fragment(adapter_instance, cached_attributes = {})
        serializer_class._cache_options ||= {}
        serializer_class._cache_options[:key] = serializer_class._cache_key if serializer_class._cache_key
        fields = serializer_class.fragmented_attributes

        non_cached_fields = fields[:non_cached].dup
        non_cached_hash = attributes(non_cached_fields, true)
        include_directive = JSONAPI::IncludeDirective.new(non_cached_fields - non_cached_hash.keys)
        non_cached_hash.merge! associations_hash({}, { include_directive: include_directive }, adapter_instance)

        cached_fields = fields[:cached].dup
        key = cache_key(adapter_instance)
        cached_hash =
          cached_attributes.fetch(key) do
            fetch(adapter_instance, serializer_class._cache_options, key) do
              hash = attributes(cached_fields, true)
              include_directive = JSONAPI::IncludeDirective.new(cached_fields - hash.keys)
              hash.merge! associations_hash({}, { include_directive: include_directive }, adapter_instance)
            end
          end
        # Merge both results
        adapter_instance.fragment_cache(cached_hash, non_cached_hash)
      end

      def cache_key(adapter_instance)
        return @cache_key if defined?(@cache_key)

        parts = []
        parts << object_cache_key
        parts << adapter_instance.cache_key
        parts << serializer_class._cache_digest unless serializer_class._skip_digest?
        @cache_key = expand_cache_key(parts)
      end

      def expand_cache_key(parts)
        ActiveSupport::Cache.expand_cache_key(parts)
      end

      # Use object's cache_key if available, else derive a key from the object
      # Pass the `key` option to the `cache` declaration or override this method to customize the cache key
      def object_cache_key
        if object.respond_to?(:cache_key)
          object.cache_key
        elsif (serializer_cache_key = (serializer_class._cache_key || serializer_class._cache_options[:key]))
          object_time_safe = object.updated_at
          object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
          "#{serializer_cache_key}/#{object.id}-#{object_time_safe}"
        else
          fail UndefinedCacheKey, "#{object.class} must define #cache_key, or the 'key:' option must be passed into '#{serializer_class}.cache'"
        end
      end

      def serializer_class
        @serializer_class ||= self.class
      end
    end
  end
end

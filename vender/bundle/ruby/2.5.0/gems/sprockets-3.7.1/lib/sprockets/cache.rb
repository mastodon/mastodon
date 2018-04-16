require 'logger'
require 'sprockets/digest_utils'

module Sprockets
  # Public: Wrapper interface to backend cache stores. Ensures a consistent API
  # even when the backend uses get/set or read/write.
  #
  # Public cache interface
  #
  # Always assign the backend store instance to Environment#cache=.
  #
  #     environment.cache = Sprockets::Cache::MemoryStore.new(1000)
  #
  # Environment#cache will always return a wrapped Cache interface. See the
  # methods marked public on this class.
  #
  #
  # Backend cache interface
  #
  # The Backend cache store must implement two methods.
  #
  # get(key)
  #
  #   key - An opaque String with a length less than 250 characters.
  #
  #   Returns an JSON serializable object.
  #
  # set(key, value)
  #
  #   Will only be called once per key. Setting a key "foo" with value "bar",
  #   then later key "foo" with value "baz" is an undefined behavior.
  #
  #   key   - An opaque String with a length less than 250 characters.
  #   value - A JSON serializable object.
  #
  #   Returns argument value.
  #
  class Cache
    # Builtin cache stores.
    autoload :FileStore,   'sprockets/cache/file_store'
    autoload :MemoryStore, 'sprockets/cache/memory_store'
    autoload :NullStore,   'sprockets/cache/null_store'

    # Internal: Cache key version for this class. Rarely should have to change
    # unless the cache format radically changes. Will be bump on major version
    # releases though.
    VERSION = '3.0'

    def self.default_logger
      logger = Logger.new($stderr)
      logger.level = Logger::FATAL
      logger
    end

    # Internal: Wrap a backend cache store.
    #
    # Always assign a backend cache store instance to Environment#cache= and
    # use Environment#cache to retreive a wrapped interface.
    #
    # cache - A compatible backend cache store instance.
    def initialize(cache = nil, logger = self.class.default_logger)
      @cache_wrapper = get_cache_wrapper(cache)
      @fetch_cache   = Cache::MemoryStore.new(1024)
      @logger        = logger
    end

    # Public: Prefer API to retrieve and set values in the cache store.
    #
    # key   - JSON serializable key
    # block -
    #   Must return a consistent JSON serializable object for the given key.
    #
    # Examples
    #
    #   cache.fetch("foo") { "bar" }
    #
    # Returns a JSON serializable object.
    def fetch(key)
      start = Time.now.to_f
      expanded_key = expand_key(key)
      value = @fetch_cache.get(expanded_key)
      if value.nil?
        value = @cache_wrapper.get(expanded_key)
        if value.nil?
          value = yield
          @cache_wrapper.set(expanded_key, value)
          @logger.debug do
            ms = "(#{((Time.now.to_f - start) * 1000).to_i}ms)"
            "Sprockets Cache miss #{peek_key(key)}  #{ms}"
          end
        end
        @fetch_cache.set(expanded_key, value)
      end
      value
    end

    # Public: Low level API to retrieve item directly from the backend cache
    # store.
    #
    # This API may be used publicly, but may have undefined behavior
    # depending on the backend store being used. Prefer the
    # Cache#fetch API over using this.
    #
    # key   - JSON serializable key
    # local - Check local cache first (default: false)
    #
    # Returns a JSON serializable object or nil if there was a cache miss.
    def get(key, local = false)
      expanded_key = expand_key(key)

      if local && value = @fetch_cache.get(expanded_key)
        return value
      end

      value = @cache_wrapper.get(expanded_key)
      @fetch_cache.set(expanded_key, value) if local

      value
    end

    # Public: Low level API to set item directly to the backend cache store.
    #
    # This API may be used publicly, but may have undefined behavior
    # depending on the backend store being used. Prefer the
    # Cache#fetch API over using this.
    #
    # key   - JSON serializable key
    # value - A consistent JSON serializable object for the given key. Setting
    #         a different value for the given key has undefined behavior.
    # local - Set on local cache (default: false)
    #
    # Returns the value argument.
    def set(key, value, local = false)
      expanded_key = expand_key(key)
      @fetch_cache.set(expanded_key, value) if local
      @cache_wrapper.set(expanded_key, value)
    end

    # Public: Pretty inspect
    #
    # Returns String.
    def inspect
      "#<#{self.class} local=#{@fetch_cache.inspect} store=#{@cache_wrapper.cache.inspect}>"
    end

    private
      # Internal: Expand object cache key into a short String key.
      #
      # The String should be under 250 characters so its compatible with
      # Memcache.
      #
      # key - JSON serializable key
      #
      # Returns a String with a length less than 250 characters.
      def expand_key(key)
        digest_key = DigestUtils.pack_urlsafe_base64digest(DigestUtils.digest(key))
        namespace = digest_key[0, 2]
        "sprockets/v#{VERSION}/#{namespace}/#{digest_key}"
      end

      PEEK_SIZE = 100

      # Internal: Show first 100 characters of cache key for logging purposes.
      #
      # Returns a String with a length less than 100 characters.
      def peek_key(key)
        case key
        when Integer
          key.to_s
        when String
          key[0, PEEK_SIZE].inspect
        when Array
          str = []
          key.each { |k| str << peek_key(k) }
          str.join(':')[0, PEEK_SIZE]
        else
          peek_key(DigestUtils.pack_urlsafe_base64digest(DigestUtils.digest(key)))
        end
      end

      def get_cache_wrapper(cache)
        if cache.is_a?(Cache)
          cache

        # `Cache#get(key)` for Memcache
        elsif cache.respond_to?(:get)
          GetWrapper.new(cache)

        # `Cache#[key]` so `Hash` can be used
        elsif cache.respond_to?(:[])
          HashWrapper.new(cache)

        # `Cache#read(key)` for `ActiveSupport::Cache` support
        elsif cache.respond_to?(:read)
          ReadWriteWrapper.new(cache)

        else
          cache = Sprockets::Cache::NullStore.new
          GetWrapper.new(cache)
        end
      end

      class Wrapper < Struct.new(:cache)
      end

      class GetWrapper < Wrapper
        def get(key)
          cache.get(key)
        end

        def set(key, value)
          cache.set(key, value)
        end
      end

      class HashWrapper < Wrapper
        def get(key)
          cache[key]
        end

        def set(key, value)
          cache[key] = value
        end
      end

      class ReadWriteWrapper < Wrapper
        def get(key)
          cache.read(key)
        end

        def set(key, value)
          cache.write(key, value)
        end
      end
  end
end

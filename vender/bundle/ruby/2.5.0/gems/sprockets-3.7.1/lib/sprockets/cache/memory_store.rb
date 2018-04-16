module Sprockets
  class Cache
    # Public: Basic in memory LRU cache.
    #
    # Assign the instance to the Environment#cache.
    #
    #     environment.cache = Sprockets::Cache::MemoryStore.new(1000)
    #
    # See Also
    #
    #   ActiveSupport::Cache::MemoryStore
    #
    class MemoryStore
      # Internal: Default key limit for store.
      DEFAULT_MAX_SIZE = 1000

      # Public: Initialize the cache store.
      #
      # max_size - A Integer of the maximum number of keys the store will hold.
      #            (default: 1000).
      def initialize(max_size = DEFAULT_MAX_SIZE)
        @max_size = max_size
        @cache = {}
      end

      # Public: Retrieve value from cache.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key - String cache key.
      #
      # Returns Object or nil or the value is not set.
      def get(key)
        exists = true
        value = @cache.delete(key) { exists = false }
        if exists
          @cache[key] = value
        else
          nil
        end
      end

      # Public: Set a key and value in the cache.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key   - String cache key.
      # value - Object value.
      #
      # Returns Object value.
      def set(key, value)
        @cache.delete(key)
        @cache[key] = value
        @cache.shift if @cache.size > @max_size
        value
      end

      # Public: Pretty inspect
      #
      # Returns String.
      def inspect
        "#<#{self.class} size=#{@cache.size}/#{@max_size}>"
      end
    end
  end
end

module Sprockets
  class Cache
    # Public: A compatible cache store that doesn't store anything. Used by
    # default when no Environment#cache is configured.
    #
    # Assign the instance to the Environment#cache.
    #
    #     environment.cache = Sprockets::Cache::NullStore.new
    #
    # See Also
    #
    #   ActiveSupport::Cache::NullStore
    #
    class NullStore
      # Public: Simulate a cache miss.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key - String cache key.
      #
      # Returns nil.
      def get(key)
        nil
      end

      # Public: Simulate setting a value in the cache.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key   - String cache key.
      # value - Object value.
      #
      # Returns Object value.
      def set(key, value)
        value
      end

      # Public: Pretty inspect
      #
      # Returns String.
      def inspect
        "#<#{self.class}>"
      end
    end
  end
end

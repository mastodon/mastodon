module MultiJson
  module OptionsCache
    extend self

    def reset
      @dump_cache = {}
      @load_cache = {}
    end

    def fetch(type, key)
      cache = instance_variable_get("@#{type}_cache")
      cache.key?(key) ? cache[key] : write(cache, key, &Proc.new)
    end

    private

    # Normally MultiJson is used with a few option sets for both dump/load
    # methods. When options are generated dynamically though, every call would
    # cause a cache miss and the cache would grow indefinitely. To prevent
    # this, we just reset the cache every time the number of keys outgrows
    # 1000.
    MAX_CACHE_SIZE = 1000

    def write(cache, key)
      cache.clear if cache.length >= MAX_CACHE_SIZE
      cache[key] = yield
    end
  end
end

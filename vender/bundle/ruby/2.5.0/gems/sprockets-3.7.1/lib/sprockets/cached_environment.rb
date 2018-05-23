require 'sprockets/base'

module Sprockets
  # `Cached` is a special cached version of `Environment`.
  #
  # The expection is that all of its file system methods are cached
  # for the instances lifetime. This makes `Cached` much faster. This
  # behavior is ideal in production environments where the file system
  # is immutable.
  #
  # `Cached` should not be initialized directly. Instead use
  # `Environment#cached`.
  class CachedEnvironment < Base
    def initialize(environment)
      initialize_configuration(environment)

      @cache   = environment.cache
      @stats   = Hash.new { |h, k| h[k] = _stat(k) }
      @entries = Hash.new { |h, k| h[k] = _entries(k) }
      @uris    = Hash.new { |h, k| h[k] = _load(k) }

      @processor_cache_keys  = Hash.new { |h, k| h[k] = _processor_cache_key(k) }
      @resolved_dependencies = Hash.new { |h, k| h[k] = _resolve_dependency(k) }
    end

    # No-op return self as cached environment.
    def cached
      self
    end
    alias_method :index, :cached

    # Internal: Cache Environment#entries
    alias_method :_entries, :entries
    def entries(path)
      @entries[path]
    end

    # Internal: Cache Environment#stat
    alias_method :_stat, :stat
    def stat(path)
      @stats[path]
    end

    # Internal: Cache Environment#load
    alias_method :_load, :load
    def load(uri)
      @uris[uri]
    end

    # Internal: Cache Environment#processor_cache_key
    alias_method :_processor_cache_key, :processor_cache_key
    def processor_cache_key(str)
      @processor_cache_keys[str]
    end

    # Internal: Cache Environment#resolve_dependency
    alias_method :_resolve_dependency, :resolve_dependency
    def resolve_dependency(str)
      @resolved_dependencies[str]
    end

    private
      # Cache is immutable, any methods that try to change the runtime config
      # should bomb.
      def config=(config)
        raise RuntimeError, "can't modify immutable cached environment"
      end
  end
end

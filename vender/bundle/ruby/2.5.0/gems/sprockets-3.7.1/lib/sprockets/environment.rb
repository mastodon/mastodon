require 'sprockets/base'
require 'sprockets/cache/memory_store'
require 'sprockets/cached_environment'

module Sprockets
  class Environment < Base
    # `Environment` should initialized with your application's root
    # directory. This should be the same as your Rails or Rack root.
    #
    #     env = Environment.new(Rails.root)
    #
    def initialize(root = ".")
      initialize_configuration(Sprockets)
      self.root = root
      self.cache = Cache::MemoryStore.new
      yield self if block_given?
    end

    # Returns a cached version of the environment.
    #
    # All its file system calls are cached which makes `cached` much
    # faster. This behavior is ideal in production since the file
    # system only changes between deploys.
    def cached
      CachedEnvironment.new(self)
    end
    alias_method :index, :cached

    def find_asset(*args)
      cached.find_asset(*args)
    end

    def find_all_linked_assets(*args, &block)
      cached.find_all_linked_assets(*args, &block)
    end

    def load(*args)
      cached.load(*args)
    end
  end
end

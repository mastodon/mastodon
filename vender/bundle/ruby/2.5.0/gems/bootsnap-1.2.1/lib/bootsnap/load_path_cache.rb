module Bootsnap
  module LoadPathCache
    ReturnFalse = Class.new(StandardError)
    FallbackScan = Class.new(StandardError)

    DOT_RB = '.rb'
    DOT_SO = '.so'
    SLASH  = '/'

    DL_EXTENSIONS = ::RbConfig::CONFIG
      .values_at('DLEXT', 'DLEXT2')
      .reject { |ext| !ext || ext.empty? }
      .map    { |ext| ".#{ext}" }
      .freeze
    DLEXT = DL_EXTENSIONS[0]
    # This is nil on linux and darwin, but I think it's '.o' on some other
    # platform.  I'm not really sure which, but it seems better to replicate
    # ruby's semantics as faithfully as possible.
    DLEXT2 = DL_EXTENSIONS[1]

    CACHED_EXTENSIONS = DLEXT2 ? [DOT_RB, DLEXT, DLEXT2] : [DOT_RB, DLEXT]

    class << self
      attr_reader :load_path_cache, :autoload_paths_cache, :loaded_features_index

      def setup(cache_path:, development_mode:, active_support: true)
        store = Store.new(cache_path)

        @loaded_features_index = LoadedFeaturesIndex.new

        @load_path_cache = Cache.new(store, $LOAD_PATH, development_mode: development_mode)
        require_relative 'load_path_cache/core_ext/kernel_require'

        if active_support
          # this should happen after setting up the initial cache because it
          # loads a lot of code. It's better to do after +require+ is optimized.
          require 'active_support/dependencies'
          @autoload_paths_cache = Cache.new(
            store,
            ::ActiveSupport::Dependencies.autoload_paths,
            development_mode: development_mode
          )
          require_relative 'load_path_cache/core_ext/active_support'
        end
      end
    end
  end
end

require_relative 'load_path_cache/path_scanner'
require_relative 'load_path_cache/path'
require_relative 'load_path_cache/cache'
require_relative 'load_path_cache/store'
require_relative 'load_path_cache/change_observer'
require_relative 'load_path_cache/loaded_features_index'

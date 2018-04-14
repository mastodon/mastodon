module Bootsnap
  module LoadPathCache
    module CoreExt
      def self.make_load_error(path)
        err = LoadError.new("cannot load such file -- #{path}")
        err.define_singleton_method(:path) { path }
        err
      end
    end
  end
end

module Kernel
  private

  alias_method :require_without_bootsnap, :require

  # Note that require registers to $LOADED_FEATURES while load does not.
  def require_with_bootsnap_lfi(path, resolved = nil)
    Bootsnap::LoadPathCache.loaded_features_index.register(path, resolved) do
      require_without_bootsnap(resolved || path)
    end
  end

  def require(path)
    return false if Bootsnap::LoadPathCache.loaded_features_index.key?(path)

    if resolved = Bootsnap::LoadPathCache.load_path_cache.find(path)
      return require_with_bootsnap_lfi(path, resolved)
    end

    raise Bootsnap::LoadPathCache::CoreExt.make_load_error(path)
  rescue Bootsnap::LoadPathCache::ReturnFalse
    return false
  rescue Bootsnap::LoadPathCache::FallbackScan
    require_with_bootsnap_lfi(path)
  end

  alias_method :load_without_bootsnap, :load
  def load(path, wrap = false)
    if resolved = Bootsnap::LoadPathCache.load_path_cache.find(path)
      return load_without_bootsnap(resolved, wrap)
    end

    # load also allows relative paths from pwd even when not in $:
    if File.exist?(relative = File.expand_path(path))
      return load_without_bootsnap(relative, wrap)
    end

    raise Bootsnap::LoadPathCache::CoreExt.make_load_error(path)
  rescue Bootsnap::LoadPathCache::ReturnFalse
    return false
  rescue Bootsnap::LoadPathCache::FallbackScan
    load_without_bootsnap(path, wrap)
  end
end

class << Kernel
  alias_method :require_without_bootsnap, :require

  def require_with_bootsnap_lfi(path, resolved = nil)
    Bootsnap::LoadPathCache.loaded_features_index.register(path, resolved) do
      require_without_bootsnap(resolved || path)
    end
  end

  def require(path)
    return false if Bootsnap::LoadPathCache.loaded_features_index.key?(path)

    if resolved = Bootsnap::LoadPathCache.load_path_cache.find(path)
      return require_with_bootsnap_lfi(path, resolved)
    end

    raise Bootsnap::LoadPathCache::CoreExt.make_load_error(path)
  rescue Bootsnap::LoadPathCache::ReturnFalse
    return false
  rescue Bootsnap::LoadPathCache::FallbackScan
    require_with_bootsnap_lfi(path)
  end

  alias_method :load_without_bootsnap, :load
  def load(path, wrap = false)
    if resolved = Bootsnap::LoadPathCache.load_path_cache.find(path)
      return load_without_bootsnap(resolved, wrap)
    end

    # load also allows relative paths from pwd even when not in $:
    if File.exist?(relative = File.expand_path(path))
      return load_without_bootsnap(relative, wrap)
    end

    raise Bootsnap::LoadPathCache::CoreExt.make_load_error(path)
  rescue Bootsnap::LoadPathCache::ReturnFalse
    return false
  rescue Bootsnap::LoadPathCache::FallbackScan
    load_without_bootsnap(path, wrap)
  end
end

class Module
  alias_method :autoload_without_bootsnap, :autoload
  def autoload(const, path)
    # NOTE: This may defeat LoadedFeaturesIndex, but it's not immediately
    # obvious how to make it work. This feels like a pretty niche case, unclear
    # if it will ever burn anyone.
    #
    # The challenge is that we don't control the point at which the entry gets
    # added to $LOADED_FEATURES and won't be able to hook that modification
    # since it's done in C-land.
    autoload_without_bootsnap(const, Bootsnap::LoadPathCache.load_path_cache.find(path) || path)
  rescue Bootsnap::LoadPathCache::ReturnFalse
    return false
  rescue Bootsnap::LoadPathCache::FallbackScan
    autoload_without_bootsnap(const, path)
  end
end

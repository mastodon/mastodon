require 'sass'

module Sprockets
  class SassProcessor
    # Internal: Cache wrapper for Sprockets cache adapter.
    class CacheStore < ::Sass::CacheStores::Base
      VERSION = '1'

      def initialize(cache, version)
        @cache, @version = cache, "#{VERSION}/#{version}"
      end

      def _store(key, version, sha, contents)
        @cache.set("#{@version}/#{version}/#{key}/#{sha}", contents, true)
      end

      def _retrieve(key, version, sha)
        @cache.get("#{@version}/#{version}/#{key}/#{sha}", true)
      end

      def path_to(key)
        key
      end
    end
  end

  # Deprecated: Use Sprockets::SassProcessor::CacheStore instead.
  class SassCacheStore < SassProcessor::CacheStore
    def initialize(*args)
      Deprecation.new.warn "SassCacheStore is deprecated please use SassProcessor::CacheStore instead"
      super
    end
  end
end

require 'sprockets/digest_utils'
require 'sprockets/path_digest_utils'
require 'sprockets/uri_utils'

module Sprockets
  # `Dependencies` is an internal mixin whose public methods are exposed on the
  # `Environment` and `CachedEnvironment` classes.
  module Dependencies
    include DigestUtils, PathDigestUtils, URIUtils

    # Public: Mapping dependency schemes to resolver functions.
    #
    # key   - String scheme
    # value - Proc.call(Environment, String)
    #
    # Returns Hash.
    def dependency_resolvers
      config[:dependency_resolvers]
    end

    # Public: Default set of dependency URIs for assets.
    #
    # Returns Set of String URIs.
    def dependencies
      config[:dependencies]
    end

    # Public: Register new dependency URI resolver.
    #
    # scheme - String scheme
    # block  -
    #   environment - Environment
    #   uri - String dependency URI
    #
    # Returns nothing.
    def register_dependency_resolver(scheme, &block)
      self.config = hash_reassoc(config, :dependency_resolvers) do |hash|
        hash.merge(scheme => block)
      end
    end

    # Public: Add environmental dependency inheirted by all assets.
    #
    # uri - String dependency URI
    #
    # Returns nothing.
    def add_dependency(uri)
      self.config = hash_reassoc(config, :dependencies) do |set|
        set + Set.new([uri])
      end
    end
    alias_method :depend_on, :add_dependency

    # Internal: Resolve dependency URIs.
    #
    # Returns resolved Object.
    def resolve_dependency(str)
      # Optimize for the most common scheme to
      # save 22k allocations on an average Spree app.
      scheme = if str.start_with?('file-digest:'.freeze)
        'file-digest'.freeze
      else
        str[/([^:]+)/, 1]
      end

      if resolver = config[:dependency_resolvers][scheme]
        resolver.call(self, str)
      else
        nil
      end
    end
  end
end

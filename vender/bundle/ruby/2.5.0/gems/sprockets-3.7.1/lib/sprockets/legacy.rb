require 'pathname'
require 'sprockets/asset'
require 'sprockets/base'
require 'sprockets/cached_environment'
require 'sprockets/context'
require 'sprockets/manifest'
require 'sprockets/resolve'

module Sprockets
  autoload :CoffeeScriptTemplate, 'sprockets/coffee_script_template'
  autoload :EcoTemplate, 'sprockets/eco_template'
  autoload :EjsTemplate, 'sprockets/ejs_template'
  autoload :ERBTemplate, 'sprockets/erb_template'
  autoload :SassTemplate, 'sprockets/sass_template'
  autoload :ScssTemplate, 'sprockets/sass_template'

  # Deprecated
  Index = CachedEnvironment

  class Base
    include Resolve

    # Deprecated: Change default return type of resolve() to return 2.x
    # compatible plain filename String. 4.x will always return an Asset URI
    # and a set of file system dependencies that had to be read to compute the
    # result.
    #
    #   2.x
    #
    #     resolve("foo.js")
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #   3.x
    #
    #     resolve("foo.js")
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #     resolve("foo.js", compat: true)
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #     resolve("foo.js", compat: false)
    #     # => [
    #     #   "file:///path/to/app/javascripts/foo.js?type=application/javascript"
    #     #    #<Set: {"file-digest:/path/to/app/javascripts/foo.js"}>
    #     # ]
    #
    #   4.x
    #
    #     resolve("foo.js")
    #     # => [
    #     #   "file:///path/to/app/javascripts/foo.js?type=application/javascript"
    #     #    #<Set: {"file-digest:/path/to/app/javascripts/foo.js"}>
    #     # ]
    #
    def resolve_with_compat(path, options = {})
      options = options.dup
      if options.delete(:compat) { true }
        uri, _ = resolve_without_compat(path, options)
        if uri
          path, _ = parse_asset_uri(uri)
          path
        else
          nil
        end
      else
        resolve_without_compat(path, options)
      end
    end
    alias_method :resolve_without_compat, :resolve
    alias_method :resolve, :resolve_with_compat

    # Deprecated: Iterate over all logical paths with a matcher.
    #
    # Remove from 4.x.
    #
    # args - List of matcher objects.
    #
    # Returns Enumerator if no block is given.
    def each_logical_path(*args, &block)
      return to_enum(__method__, *args) unless block_given?

      filters = args.flatten.map { |arg| Manifest.compile_match_filter(arg) }
      logical_paths.each do |a, b|
        if filters.any? { |f| f.call(a, b) }
          if block.arity == 2
            yield a, b
          else
            yield a
          end
        end
      end

      nil
    end

    # Deprecated: Enumerate over all logical paths in the environment.
    #
    # Returns an Enumerator of [logical_path, filename].
    def logical_paths
      return to_enum(__method__) unless block_given?

      seen = Set.new

      paths.each do |load_path|
        stat_tree(load_path).each do |filename, stat|
          next unless stat.file?

          path = split_subpath(load_path, filename)
          path, mime_type, _, _ = parse_path_extnames(path)
          path = normalize_logical_path(path)
          path += mime_types[mime_type][:extensions].first if mime_type

          if !seen.include?(path)
            yield path, filename
            seen << path
          end
        end
      end

      nil
    end

    def cache_get(key)
      cache.get(key)
    end

    def cache_set(key, value)
      cache.set(key, value)
    end

    def normalize_logical_path(path)
      dirname, basename = File.split(path)
      path = dirname if basename == 'index'
      path
    end

    private
      # Deprecated: Seriously.
      def matches_filter(filters, logical_path, filename)
        return true if filters.empty?

        filters.any? do |filter|
          if filter.is_a?(Regexp)
            filter.match(logical_path)
          elsif filter.respond_to?(:call)
            if filter.arity == 1
              filter.call(logical_path)
            else
              filter.call(logical_path, filename.to_s)
            end
          else
            File.fnmatch(filter.to_s, logical_path)
          end
        end
      end

      # URI.unescape is deprecated on 1.9. We need to use URI::Parser
      # if its available.
      if defined? URI::DEFAULT_PARSER
        def unescape(str)
          str = URI::DEFAULT_PARSER.unescape(str)
          str.force_encoding(Encoding.default_internal) if Encoding.default_internal
          str
        end
      else
        def unescape(str)
          URI.unescape(str)
        end
      end
  end

  class Asset
    # Deprecated: Use #filename instead.
    #
    # Returns Pathname.
    def pathname
      @pathname ||= Pathname.new(filename)
    end

    # Deprecated: Expand asset into an `Array` of parts.
    #
    # Appending all of an assets body parts together should give you
    # the asset's contents as a whole.
    #
    # This allows you to link to individual files for debugging
    # purposes.
    #
    # Use Asset#included instead. Keeping a full copy of the bundle's processed
    # assets in memory (and in cache) is expensive and redundant. The common use
    # case is to relink to the assets anyway.
    #
    # Returns Array of Assets.
    def to_a
      if metadata[:included]
        metadata[:included].map { |uri| @environment.load(uri) }
      else
        [self]
      end
    end

    # Deprecated: Get all required Assets.
    #
    # See Asset#to_a
    #
    # Returns Array of Assets.
    def dependencies
      to_a.reject { |a| a.filename.eql?(self.filename) }
    end

    # Deprecated: Returns Time of the last time the source was modified.
    #
    # Time resolution is normalized to the nearest second.
    #
    # Returns Time.
    def mtime
      Time.at(@mtime)
    end
  end

  class Context
    # Deprecated: Change default return type of resolve() to return 2.x
    # compatible plain filename String. 4.x will always return an Asset URI.
    #
    #   2.x
    #
    #     resolve("foo.js")
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #   3.x
    #
    #     resolve("foo.js")
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #     resolve("foo.js", compat: true)
    #     # => "/path/to/app/javascripts/foo.js"
    #
    #     resolve("foo.js", compat: false)
    #     # => "file:///path/to/app/javascripts/foo.js?type=application/javascript"
    #
    #   4.x
    #
    #     resolve("foo.js")
    #     # => "file:///path/to/app/javascripts/foo.js?type=application/javascript"
    #
    def resolve_with_compat(path, options = {})
      options = options.dup

      # Support old :content_type option, prefer :accept going forward
      if type = options.delete(:content_type)
        type = self.content_type if type == :self
        options[:accept] ||= type
      end

      if options.delete(:compat) { true }
        uri = resolve_without_compat(path, options)
        path, _ = environment.parse_asset_uri(uri)
        path
      else
        resolve_without_compat(path, options)
      end
    end
    alias_method :resolve_without_compat, :resolve
    alias_method :resolve, :resolve_with_compat
  end

  class Manifest
    # Deprecated: Compile logical path matching filter into a proc that can be
    # passed to logical_paths.select(&proc).
    #
    #   compile_match_filter(proc { |logical_path|
    #     File.extname(logical_path) == '.js'
    #   })
    #
    #   compile_match_filter(/application.js/)
    #
    #   compile_match_filter("foo/*.js")
    #
    # Returns a Proc or raise a TypeError.
    def self.compile_match_filter(filter)
      # If the filter is already a proc, great nothing to do.
      if filter.respond_to?(:call)
        filter
      # If the filter is a regexp, wrap it in a proc that tests it against the
      # logical path.
      elsif filter.is_a?(Regexp)
        proc { |logical_path| filter.match(logical_path) }
      elsif filter.is_a?(String)
        # If its an absolute path, detect the matching full filename
        if PathUtils.absolute_path?(filter)
          proc { |logical_path, filename| filename == filter.to_s }
        else
          # Otherwise do an fnmatch against the logical path.
          proc { |logical_path| File.fnmatch(filter.to_s, logical_path) }
        end
      else
        raise TypeError, "unknown filter type: #{filter.inspect}"
      end
    end

    def self.simple_logical_path?(str)
      str.is_a?(String) &&
        !PathUtils.absolute_path?(str) &&
        str !~ /\*|\*\*|\?|\[|\]|\{|\}/
    end

    def self.compute_alias_logical_path(path)
      dirname, basename = File.split(path)
      extname = File.extname(basename)
      if File.basename(basename, extname) == 'index'
        "#{dirname}#{extname}"
      else
        nil
      end
    end

    # Deprecated: Filter logical paths in environment. Useful for selecting what
    # files you want to compile.
    #
    # Returns an Enumerator.
    def filter_logical_paths(*args)
      filters = args.flatten.map { |arg| self.class.compile_match_filter(arg) }
      environment.cached.logical_paths.select do |a, b|
        filters.any? { |f| f.call(a, b) }
      end
    end

    # Deprecated alias.
    alias_method :find_logical_paths, :filter_logical_paths
  end
end

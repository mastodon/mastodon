require 'pathname'
require 'rack/utils'
require 'set'
require 'sprockets/errors'

module Sprockets
  # Deprecated: `Context` provides helper methods to all processors.
  # They are typically accessed by ERB templates. You can mix in custom helpers
  # by injecting them into `Environment#context_class`. Do not mix them into
  # `Context` directly.
  #
  #     environment.context_class.class_eval do
  #       include MyHelper
  #       def asset_url; end
  #     end
  #
  #     <%= asset_url "foo.png" %>
  #
  # The `Context` also collects dependencies declared by
  # assets. See `DirectiveProcessor` for an example of this.
  class Context
    attr_reader :environment, :filename, :pathname

    # Deprecated
    attr_accessor :__LINE__

    def initialize(input)
      @environment  = input[:environment]
      @metadata     = input[:metadata]
      @load_path    = input[:load_path]
      @logical_path = input[:name]
      @filename     = input[:filename]
      @dirname      = File.dirname(@filename)
      @pathname     = Pathname.new(@filename)
      @content_type = input[:content_type]

      @required     = Set.new(@metadata[:required])
      @stubbed      = Set.new(@metadata[:stubbed])
      @links        = Set.new(@metadata[:links])
      @dependencies = Set.new(input[:metadata][:dependencies])
    end

    def metadata
      { required: @required,
        stubbed: @stubbed,
        links: @links,
        dependencies: @dependencies }
    end

    # Returns the environment path that contains the file.
    #
    # If `app/javascripts` and `app/stylesheets` are in your path, and
    # current file is `app/javascripts/foo/bar.js`, `load_path` would
    # return `app/javascripts`.
    attr_reader :load_path
    alias_method :root_path, :load_path

    # Returns logical path without any file extensions.
    #
    #     'app/javascripts/application.js'
    #     # => 'application'
    #
    attr_reader :logical_path

    # Returns content type of file
    #
    #     'application/javascript'
    #     'text/css'
    #
    attr_reader :content_type

    # Public: Given a logical path, `resolve` will find and return an Asset URI.
    # Relative paths will also be resolved. An accept type maybe given to
    # restrict the search.
    #
    #     resolve("foo.js")
    #     # => "file:///path/to/app/javascripts/foo.js?type=application/javascript"
    #
    #     resolve("./bar.js")
    #     # => "file:///path/to/app/javascripts/bar.js?type=application/javascript"
    #
    # path - String logical or absolute path
    # options
    #   accept - String content accept type
    #
    # Returns an Asset URI String.
    def resolve(path, options = {})
      uri, deps = environment.resolve!(path, options.merge(base_path: @dirname))
      @dependencies.merge(deps)
      uri
    end

    # Public: Load Asset by AssetURI and track it as a dependency.
    #
    # uri - AssetURI
    #
    # Returns Asset.
    def load(uri)
      asset = environment.load(uri)
      @dependencies.merge(asset.metadata[:dependencies])
      asset
    end

    # `depend_on` allows you to state a dependency on a file without
    # including it.
    #
    # This is used for caching purposes. Any changes made to
    # the dependency file with invalidate the cache of the
    # source file.
    def depend_on(path)
      path = path.to_s if path.is_a?(Pathname)

      if environment.absolute_path?(path) && environment.stat(path)
        @dependencies << environment.build_file_digest_uri(path)
      else
        resolve(path, compat: false)
      end
      nil
    end

    # `depend_on_asset` allows you to state an asset dependency
    # without including it.
    #
    # This is used for caching purposes. Any changes that would
    # invalidate the dependency asset will invalidate the source
    # file. Unlike `depend_on`, this will include recursively include
    # the target asset's dependencies.
    def depend_on_asset(path)
      load(resolve(path, compat: false))
    end

    # `require_asset` declares `path` as a dependency of the file. The
    # dependency will be inserted before the file and will only be
    # included once.
    #
    # If ERB processing is enabled, you can use it to dynamically
    # require assets.
    #
    #     <%= require_asset "#{framework}.js" %>
    #
    def require_asset(path)
      @required << resolve(path, accept: @content_type, pipeline: :self, compat: false)
      nil
    end

    # `stub_asset` blacklists `path` from being included in the bundle.
    # `path` must be an asset which may or may not already be included
    # in the bundle.
    def stub_asset(path)
      @stubbed << resolve(path, accept: @content_type, pipeline: :self, compat: false)
      nil
    end

    # `link_asset` declares an external dependency on an asset without directly
    # including it. The target asset is returned from this function making it
    # easy to construct a link to it.
    #
    # Returns an Asset or nil.
    def link_asset(path)
      asset = depend_on_asset(path)
      @links << asset.uri
      asset
    end

    # Returns a Base64-encoded `data:` URI with the contents of the
    # asset at the specified path, and marks that path as a dependency
    # of the current file.
    #
    # Use `asset_data_uri` from ERB with CSS or JavaScript assets:
    #
    #     #logo { background: url(<%= asset_data_uri 'logo.png' %>) }
    #
    #     $('<img>').attr('src', '<%= asset_data_uri 'avatar.jpg' %>')
    #
    def asset_data_uri(path)
      asset = depend_on_asset(path)
      data = EncodingUtils.base64(asset.source)
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(data)}"
    end

    # Expands logical path to full url to asset.
    #
    # NOTE: This helper is currently not implemented and should be
    # customized by the application. Though, in the future, some
    # basics implemention may be provided with different methods that
    # are required to be overridden.
    def asset_path(path, options = {})
      message = <<-EOS
Custom asset_path helper is not implemented

Extend your environment context with a custom method.

    environment.context_class.class_eval do
      def asset_path(path, options = {})
      end
    end
      EOS
      raise NotImplementedError, message
    end

    # Expand logical image asset path.
    def image_path(path)
      asset_path(path, type: :image)
    end

    # Expand logical video asset path.
    def video_path(path)
      asset_path(path, type: :video)
    end

    # Expand logical audio asset path.
    def audio_path(path)
      asset_path(path, type: :audio)
    end

    # Expand logical font asset path.
    def font_path(path)
      asset_path(path, type: :font)
    end

    # Expand logical javascript asset path.
    def javascript_path(path)
      asset_path(path, type: :javascript)
    end

    # Expand logical stylesheet asset path.
    def stylesheet_path(path)
      asset_path(path, type: :stylesheet)
    end
  end
end

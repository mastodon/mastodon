require 'rack/utils'
require 'sprockets/autoload'
require 'uri'

module Sprockets
  # Processor engine class for the SASS/SCSS compiler. Depends on the `sass` gem.
  #
  # For more infomation see:
  #
  #   https://github.com/sass/sass
  #   https://github.com/rails/sass-rails
  #
  class SassProcessor
    autoload :CacheStore, 'sprockets/sass_cache_store'

    # Internal: Defines default sass syntax to use. Exposed so the ScssProcessor
    # may override it.
    def self.syntax
      :sass
    end

    # Public: Return singleton instance with default options.
    #
    # Returns SassProcessor object.
    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def self.cache_key
      instance.cache_key
    end

    attr_reader :cache_key

    # Public: Initialize template with custom options.
    #
    # options - Hash
    # cache_version - String custom cache version. Used to force a cache
    #                 change after code changes are made to Sass Functions.
    #
    def initialize(options = {}, &block)
      @cache_version = options[:cache_version]
      @cache_key = "#{self.class.name}:#{VERSION}:#{Autoload::Sass::VERSION}:#{@cache_version}".freeze

      @functions = Module.new do
        include Functions
        include options[:functions] if options[:functions]
        class_eval(&block) if block_given?
      end
    end

    def call(input)
      context = input[:environment].context_class.new(input)

      options = {
        filename: input[:filename],
        syntax: self.class.syntax,
        cache_store: build_cache_store(input, @cache_version),
        load_paths: input[:environment].paths,
        sprockets: {
          context: context,
          environment: input[:environment],
          dependencies: context.metadata[:dependencies]
        }
      }

      engine = Autoload::Sass::Engine.new(input[:data], options)

      css = Utils.module_include(Autoload::Sass::Script::Functions, @functions) do
        engine.render
      end

      # Track all imported files
      sass_dependencies = Set.new([input[:filename]])
      engine.dependencies.map do |dependency|
        sass_dependencies << dependency.options[:filename]
        context.metadata[:dependencies] << URIUtils.build_file_digest_uri(dependency.options[:filename])
      end

      context.metadata.merge(data: css, sass_dependencies: sass_dependencies)
    end

    # Public: Build the cache store to be used by the Sass engine.
    #
    # input - the input hash.
    # version - the cache version.
    #
    # Override this method if you need to use a different cache than the
    # Sprockets cache.
    def build_cache_store(input, version)
      CacheStore.new(input[:cache], version)
    end
    private :build_cache_store

    # Public: Functions injected into Sass context during Sprockets evaluation.
    #
    # This module may be extended to add global functionality to all Sprockets
    # Sass environments. Though, scoping your functions to just your environment
    # is preferred.
    #
    # module Sprockets::SassProcessor::Functions
    #   def asset_path(path, options = {})
    #   end
    # end
    #
    module Functions
      # Public: Generate a url for asset path.
      #
      # Default implementation is deprecated. Currently defaults to
      # Context#asset_path.
      #
      # Will raise NotImplementedError in the future. Users should provide their
      # own base implementation.
      #
      # Returns a Sass::Script::String.
      def asset_path(path, options = {})
        path = path.value

        path, _, query, fragment = URI.split(path)[5..8]
        path     = sprockets_context.asset_path(path, options)
        query    = "?#{query}" if query
        fragment = "##{fragment}" if fragment

        Autoload::Sass::Script::String.new("#{path}#{query}#{fragment}", :string)
      end

      # Public: Generate a asset url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def asset_url(path, options = {})
        Autoload::Sass::Script::String.new("url(#{asset_path(path, options).value})")
      end

      # Public: Generate url for image path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def image_path(path)
        asset_path(path, type: :image)
      end

      # Public: Generate a image url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def image_url(path)
        asset_url(path, type: :image)
      end

      # Public: Generate url for video path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def video_path(path)
        asset_path(path, type: :video)
      end

      # Public: Generate a video url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def video_url(path)
        asset_url(path, type: :video)
      end

      # Public: Generate url for audio path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def audio_path(path)
        asset_path(path, type: :audio)
      end

      # Public: Generate a audio url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def audio_url(path)
        asset_url(path, type: :audio)
      end

      # Public: Generate url for font path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def font_path(path)
        asset_path(path, type: :font)
      end

      # Public: Generate a font url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def font_url(path)
        asset_url(path, type: :font)
      end

      # Public: Generate url for javascript path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def javascript_path(path)
        asset_path(path, type: :javascript)
      end

      # Public: Generate a javascript url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def javascript_url(path)
        asset_url(path, type: :javascript)
      end

      # Public: Generate url for stylesheet path.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def stylesheet_path(path)
        asset_path(path, type: :stylesheet)
      end

      # Public: Generate a stylesheet url() link.
      #
      # path - Sass::Script::String URL path
      #
      # Returns a Sass::Script::String.
      def stylesheet_url(path)
        asset_url(path, type: :stylesheet)
      end

      # Public: Generate a data URI for asset path.
      #
      # path - Sass::Script::String logical asset path
      #
      # Returns a Sass::Script::String.
      def asset_data_url(path)
        url = sprockets_context.asset_data_uri(path.value)
        Autoload::Sass::Script::String.new("url(" + url + ")")
      end

      protected
        # Public: The Environment.
        #
        # Returns Sprockets::Environment.
        def sprockets_environment
          options[:sprockets][:environment]
        end

        # Public: Mutatable set of dependencies.
        #
        # Returns a Set.
        def sprockets_dependencies
          options[:sprockets][:dependencies]
        end

        # Deprecated: Get the Context instance. Use APIs on
        # sprockets_environment or sprockets_dependencies directly.
        #
        # Returns a Context instance.
        def sprockets_context
          options[:sprockets][:context]
        end

    end
  end

  class ScssProcessor < SassProcessor
    def self.syntax
      :scss
    end
  end

  # Deprecated: Use Sprockets::SassProcessor::Functions instead.
  SassFunctions = SassProcessor::Functions
end

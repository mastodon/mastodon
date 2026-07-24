# frozen_string_literal: true

module Vite
  class Tagger
    # When Vite's dev server is running we just need to generate tags
    # linking to the main assets (javascript, stylesheets, etc) and the
    # dev server will do the rest
    class DevServerStrategy
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def vite_javascript_tag(helper, *names, type: 'module', crossorigin: '', asset_type: '', **) # rubocop:disable Lint/UnusedMethodArgument
        scripts = NameResolver.resolve(*names)

        helper.javascript_include_tag(*scripts, crossorigin:, type:, extname: false, **)
      end

      def vite_stylesheet_tag(helper, *names, type: :stylesheet, **options) # rubocop:disable Lint/UnusedMethodArgument
        style_paths = NameResolver.resolve(*names)

        options[:extname] = false if Rails::VERSION::MAJOR >= 7

        helper.stylesheet_link_tag(*style_paths, **options)
      end

      def vite_client_tag(helper, crossorigin: 'anonymous', **)
        src = "#{Vite.config.base_path}@vite/client"
        helper.javascript_include_tag(src, type: 'module', extname: false, crossorigin:, **)
      end

      def vite_react_refresh_tag(helper, **options)
        options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

        preamble = <<~REACT_PREAMBLE_CODE.html_safe # rubocop:disable Rails/OutputSafety
          import RefreshRuntime from '#{Vite.config.base_path}@react-refresh'
          RefreshRuntime.injectIntoGlobalHook(window)
          window.$RefreshReg$ = () => {}
          window.$RefreshSig$ = () => (type) => type
          window.__vite_plugin_react_preamble_installed__ = true
        REACT_PREAMBLE_CODE

        helper.javascript_tag(preamble, type: :module, **options)
      end

      def vite_asset_path(helper, name, **_options)
        helper.path_to_asset NameResolver.resolve(*name).first
      end

      def vite_polyfills_tag(_helper)
        ''
      end

      def vite_preload_file_tag(helper, name, crossorigin: 'anonymous', **)
        name = NameResolver.resolve(*name).first
        vite_preload_tag(helper, name, crossorigin:, **)
      end

      def vite_preload_tag(helper, *sources, crossorigin:, **options)
        url_options = options.extract!(:host, :protocol)
        asset_paths = sources.map { |source| helper.path_to_asset(source, **url_options) }
        helper.try(:request).try(
          :send_early_hints,
          'Link' => asset_paths.map do |href|
            %(<#{href}>; rel=modulepreload; as=script; crossorigin=#{crossorigin})
          end.join(',')
        )

        tags = asset_paths.map do |href|
          helper.tag.link(rel: 'modulepreload', href:, as: 'script', crossorigin:, **options)
        end

        helper.safe_join(tags)
      end
    end

    # TODO: Build tags from manifest files
    class ManifestStrategy
      attr_reader :config

      def initialize(config)
        @config = config
      end
    end

    attr_reader :strategies

    def initialize(config)
      @strategies = []
      @strategies << DevServerStrategy.new(config) if config.tag_strategies.include?(:dev_server) && Vite.dev_server.running?
    end

    def method_missing(method, ...)
      return super unless method.to_s.start_with?('vite_')

      strategies.lazy.map { |s| s.__send__(method, ...) }.find { |t| !t.nil? }
    end

    def respond_to_missing?(method, include_private = false)
      return super unless method.to_s.start_with?('vite_')

      strategies.all? { |s| s.respond_to?(method, include_private) }
    end
  end
end

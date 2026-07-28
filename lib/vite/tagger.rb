# frozen_string_literal: true

module Vite
  class Tagger
    module Common
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

    # When Vite's dev server is running we just need to generate tags
    # linking to the main assets (javascript, stylesheets, etc) and the
    # dev server will do the rest
    class DevServerStrategy
      include Common

      attr_reader :config, :resolver, :dev_server

      def initialize(config:, dev_server:)
        @config = config
        @dev_server = dev_server || DevServer.new(config:)
        @resolver = NameResolver.new(config:)
      end

      def vite_client_tag(helper, crossorigin: 'anonymous', **)
        return unless dev_server.running?

        src = resolver.bundle_path('@vite/client')
        helper.javascript_include_tag(src, type: 'module', extname: false, crossorigin:, **)
      end

      def vite_react_refresh_tag(helper, **options)
        return unless dev_server.running?

        options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

        preamble = <<~REACT_PREAMBLE_CODE.html_safe # rubocop:disable Rails/OutputSafety
          import RefreshRuntime from '#{config.base_path}@react-refresh'
          RefreshRuntime.injectIntoGlobalHook(window)
          window.$RefreshReg$ = () => {}
          window.$RefreshSig$ = () => (type) => type
          window.__vite_plugin_react_preamble_installed__ = true
        REACT_PREAMBLE_CODE

        helper.javascript_tag(preamble, type: :module, **options)
      end

      def vite_javascript_tag(helper, *names, type: 'module', crossorigin: '', asset_type: '', **) # rubocop:disable Lint/UnusedMethodArgument
        return unless dev_server.running?

        scripts = names.map { |name| resolver.full_path(name) }

        helper.javascript_include_tag(*scripts, crossorigin:, type:, extname: false, **)
      end

      def vite_stylesheet_tag(helper, *names, type: :stylesheet, **options) # rubocop:disable Lint/UnusedMethodArgument
        return unless dev_server.running?

        style_paths = names.map { |name| resolver.full_path(name) }

        options[:extname] = false if Rails::VERSION::MAJOR >= 7

        helper.stylesheet_link_tag(*style_paths, **options)
      end

      def vite_asset_path(helper, name, **_options)
        return unless dev_server.running?

        helper.path_to_asset resolver.full_path(name)
      end

      def vite_polyfills_tag(*)
        ''
      end

      def vite_preload_file_tag(helper, name, crossorigin: 'anonymous', **)
        return unless dev_server.running?

        vite_preload_tag(helper, resolver.full_path(name), crossorigin:, **)
      end
    end

    # FIXME: Control missing entries
    class ManifestStrategy
      include Common

      attr_reader :config, :manifest, :resolver

      def initialize(config:, manifest: nil)
        @config = config
        @manifest = manifest || Manifest.new(config:).tap(&:load)
        @resolver = NameResolver.new(config:)
      end

      def vite_client_tag(*)
        ''
      end

      def vite_react_refresh_tag(*)
        ''
      end

      def vite_javascript_tag(helper, *names, type: 'module', crossorigin: '', asset_type: '', media: nil, **)
        names = names.map { |name| resolver.entrypoint_path(name) }

        scripts = []
        preloads = []
        stylesheets = []
        entries = names.map { |name| manifest.fetch!(name, type: asset_type) }

        entries.each do |entry|
          scripts << helper.javascript_include_tag(
            resolver.bundle_path(entry.file),
            integrity: entry.integrity,
            crossorigin:,
            type:,
            extname: false,
            **
          )

          preloads = entry.imports.map do |import|
            vite_preload_tag(
              helper,
              resolver.bundle_path(import.file),
              integrity: import.integrity,
              crossorigin:,
              **
            )
          end

          stylesheets = entry.stylesheets.map do |stylesheet|
            helper.stylesheet_link_tag(
              resolver.bundle_path(stylesheet.file),
              integrity: stylesheet.integrity,
              crossorigin:,
              media:,
              **
            )
          end
        end

        helper.safe_join(scripts + preloads + stylesheets)
      end

      def vite_stylesheet_tag(helper, *names, type: :stylesheet, **options)
        options[:extname] = false if Rails::VERSION::MAJOR >= 7

        stylesheets = names.map do |name|
          entry = manifest.fetch!(resolver.entrypoint_path(name), type:)
          helper.stylesheet_link_tag(
            resolver.bundle_path(entry.file),
            integrity: entry.integrity,
            **options
          )
        end

        helper.safe_join(stylesheets)
      end

      def vite_asset_path(helper, name, type: nil, **)
        entry = manifest.fetch!(resolver.entrypoint_path(name), type:)
        helper.path_to_asset resolver.bundle_path(entry.file)
      end

      def vite_polyfills_tag(helper, crossorigin: 'anonymous', **)
        entry = manifest.fetch!('polyfills', type: :virtual)

        helper.javascript_include_tag(
          resolver.bundle_path(entry.file),
          type: 'module',
          integrity: entry.integrity,
          crossorigin:,
          **
        )
      end

      def vite_preload_file_tag(helper, name, crossorigin: 'anonymous', **)
        entry = manifest.fetch(resolver.entrypoint_path(name))
        return unless entry

        vite_preload_tag(helper, resolver.bundle_path(entry.file), integrity: entry.integrity, crossorigin:, **)
      end
    end

    attr_reader :strategies

    def initialize(config:, manifest: nil, dev_server: nil)
      @strategies = []
      @strategies << DevServerStrategy.new(config:, dev_server:) if config.tag_strategies.include?(:dev_server)
      @strategies << ManifestStrategy.new(config:, manifest:) if config.tag_strategies.include?(:manifest)
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

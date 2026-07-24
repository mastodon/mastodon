# frozen_string_literal: true

module Vite
  module TagsHelper
    # Temporary vite helper stubs
    # TODO: Integrity

    def vite_javascript_tag(*names, type: 'module', crossorigin: '', **)
      scripts = NameResolver.resolve(*names)

      javascript_include_tag(*scripts, crossorigin: crossorigin, type: type, extname: false, **)
    end

    def vite_typescript_tag(*names, **)
      vite_javascript_tag(*names, asset_type: :typescript, **)
    end

    def vite_stylesheet_tag(*names, type: :stylesheet, **options) # rubocop:disable Lint/UnusedMethodArgument
      style_paths = NameResolver.resolve(*names)

      options[:extname] = false if Rails::VERSION::MAJOR >= 7

      stylesheet_link_tag(*style_paths, **options)
    end

    def vite_client_tag(crossorigin: 'anonymous', **)
      src = "#{Vite.config.base_path}@vite/client"
      javascript_include_tag(src, type: 'module', extname: false, crossorigin: crossorigin, **)
    end

    def vite_react_refresh_tag(**options)
      options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

      preamble = <<~REACT_PREAMBLE_CODE.html_safe # rubocop:disable Rails/OutputSafety
        import RefreshRuntime from '#{Vite.config.base_path}@react-refresh'
        RefreshRuntime.injectIntoGlobalHook(window)
        window.$RefreshReg$ = () => {}
        window.$RefreshSig$ = () => (type) => type
        window.__vite_plugin_react_preamble_installed__ = true
      REACT_PREAMBLE_CODE

      javascript_tag(preamble, type: :module, **options)
    end

    def vite_asset_path(name, **_options)
      path_to_asset NameResolver.resolve(*name).first
    end

    # TODO: This is only necessary if there is no dev server
    def vite_polyfills_tag
      ''
    end

    def vite_preload_file_tag(name, crossorigin: 'anonymous', **)
      name = NameResolver.resolve(*name).first
      vite_preload_tag(name, crossorigin:, **)
    end

    def vite_preload_tag(*sources, crossorigin:, **options)
      url_options = options.extract!(:host, :protocol)
      asset_paths = sources.map { |source| path_to_asset(source, **url_options) }
      try(:request).try(
        :send_early_hints,
        'Link' => asset_paths.map do |href|
          %(<#{href}>; rel=modulepreload; as=script; crossorigin=#{crossorigin})
        end.join(',')
      )

      tags = asset_paths.map do |href|
        tag.link(rel: 'modulepreload', href: href, as: 'script', crossorigin: crossorigin, **options)
      end

      safe_join(tags)
    end
  end
end

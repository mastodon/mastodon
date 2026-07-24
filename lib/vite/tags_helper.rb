# frozen_string_literal: true

module Vite
  module TagsHelper
    # Temporary vite helper stubs
    # TODO: Integrity

    def vite_javascript_tag(*names, type: 'module', crossorigin: '', **)
      scripts = names.map do |name|
        # If the name is single file we assume it is inside app/javascripts/entrypoints
        name.include?('/') ? "#{Vite.config.base_path}#{name}" : "#{Vite.config.base_path}entrypoints/#{name}"
      end

      javascript_include_tag(*scripts, crossorigin: crossorigin, type: type, extname: false, **)
    end

    def vite_typescript_tag(*names, **)
      vite_javascript_tag(*names, asset_type: :typescript, **)
    end

    def vite_stylesheet_tag(*names, type: :stylesheet, **options) # rubocop:disable Lint/UnusedMethodArgument
      style_paths = names.map do |name|
        # If the name is single file we assume it is inside app/javascripts/entrypoints
        name.include?('/') ? "#{Vite.config.base_path}#{name}" : "#{Vite.config.base_path}entrypoints/#{name}"
      end

      options[:extname] = false if Rails::VERSION::MAJOR >= 7

      stylesheet_link_tag(*style_paths, **options)
    end

    def vite_client_tag(crossorigin: 'anonymous', **)
      src = "#{Vite.config.base_path}@vite/client"
      javascript_include_tag(src, type: 'module', extname: false, crossorigin: crossorigin, **)
    end

    def vite_react_refresh_tag(**options)
      options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

      preamble = <<~REACT_PREAMBLE_CODE
        import RefreshRuntime from '#{Vite.config.base_path}@react-refresh'
        RefreshRuntime.injectIntoGlobalHook(window)
        window.$RefreshReg$ = () => {}
        window.$RefreshSig$ = () => (type) => type
        window.__vite_plugin_react_preamble_installed__ = true
      REACT_PREAMBLE_CODE

      javascript_tag(preamble.html_safe, type: :module, **options) # rubocop:disable Rails/OutputSafety
    end

    def vite_asset_path(name, **_options)
      asset = name.include?('/') ? "#{Vite.config.base_path}#{name}" : "#{Vite.config.base_path}entrypoints/#{name}"
      path_to_asset asset
    end

    def vite_polyfills_tag
      ''
    end

    def vite_preload_file_tag(*)
      ''
    end
  end
end

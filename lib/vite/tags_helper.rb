# frozen_string_literal: true

module Vite
  module TagsHelper
    # Temporary vite helper stubs
    # TODO: Integrity

    def vite_javascript_tag(*names, type: 'module', crossorigin: '', **)
      Vite.tagger.vite_javascript_tag(self, *names, type:, crossorigin:, **)
    end

    def vite_typescript_tag(*names, **)
      vite_javascript_tag(*names, asset_type: :typescript, **)
    end

    def vite_stylesheet_tag(*names, type: :stylesheet, **)
      Vite.tagger.vite_stylesheet_tag(self, *names, type:, **)
    end

    def vite_client_tag(crossorigin: 'anonymous', **)
      Vite.tagger.vite_client_tag(self, crossorigin:, **)
    end

    def vite_react_refresh_tag(**)
      Vite.tagger.vite_react_refresh_tag(self, **)
    end

    def vite_asset_path(name, **)
      Vite.tagger.vite_asset_path(self, name, **)
    end

    def vite_polyfills_tag
      Vite.tagger.vite_polyfills_tag(self)
    end

    def vite_preload_file_tag(name, crossorigin: 'anonymous', **)
      Vite.tagger.vite_preload_file_tag(self, name, crossorigin:, **)
    end

    def vite_preload_tag(*sources, crossorigin:, **)
      Vite.tagger.vite_preload_tag(self, *sources, crossorigin:, **)
    end
  end
end

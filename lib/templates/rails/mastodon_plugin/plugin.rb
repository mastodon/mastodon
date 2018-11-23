# frozen_string_literal: true

module Mastodon
  module Plugins
    class <%= plugin_class_name %> < Mastodon::Plugin
      use_assets
      use_translations
      use_classes
    end
  end
end

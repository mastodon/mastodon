# frozen_string_literal: true

module Mastodon
  module Plugins
    class <%= plugin_class_name %> < Mastodon::Plugin
      # uncomment this line to prevent Mastodon from loading this plugin
      # disable!

      # automatically load assets (js, scss, and various image types) under the /assets directory
      use_assets

      # automatically load translation files under the /locales directory
      use_translations

      # automatically load ruby classes under the /app directory
      use_classes
    end
  end
end

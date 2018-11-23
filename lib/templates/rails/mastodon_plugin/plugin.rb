# frozen_string_literal: true

module Mastodon
  module Plugins
    class <%= plugin_class_name %> < Mastodon::Plugin
      # automatically loads files from this plugin directory
      # all ruby files go under /app
      # all assets (js, scss, and images) go under /assets
      # all translation files go under /locales
      initialize!

      # uncomment this line to prevent Mastodon from loading this plugin
      # disable!
    end
  end
end

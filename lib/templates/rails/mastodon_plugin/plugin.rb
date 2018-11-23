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

      # add a React component to the interface via an outlet
      # use_outlet "assets/my-component.js", "outlet-name"

      # add paths to the routes file
      # use_routes do
      #   get "api/v1/example", to: "api/examples#index"
      # end

      # add an extension to an existing class
      # use_extension "ExistingClass" do
      #   def hello_world
      #     puts "hello world!"
      #   end
      # end
    end
  end
end

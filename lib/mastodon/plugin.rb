# frozen_string_literal: true
require_relative './plugin_utils'

module Mastodon
  class Plugin
    extend PluginUtils
    NamedPath = Struct.new(:name, :path, :type)

    @@actions = Set.new
    @@paths   = Set.new
    @@assets  = Set.new

    cattr_reader :actions
    cattr_reader :paths
    cattr_reader :assets

    def self.use_classes
      @@actions.add(proc {
        folders_in_directory('app') { |path| ActiveSupport::Dependencies.autoload_paths << path }
      })
    end

    def self.use_assets
      files_in_directory('assets', '{js,scss,jpg,jpeg,png,svg}') { |asset| @@assets.add(asset) }
    end

    # Add translation overrides
    # example usage: `use_translations("locales")`
    # ^^ search for all .js files (for example en.js) for translation overrides in the
    # NB: The translation files take the following format:
    # module.exports = {
    #   "<translation_key>": "overriding value"
    # }
    def self.use_translations(path = 'locales')
      files_in_directory('locales', 'js') do |path|
        file = path.split('/').last.gsub('.js', '')
        @@paths.add NamedPath.new(file, relative_path_prefix(path), :locales)
      end
    end

    def self.use_outlet(path, outlet)
      @@paths.add NamedPath.new(outlet, relative_path_prefix(path), :outlets)
    end

    # Add an api route
    # example usage: `use_route(:get, "examples/:id", "examples#show")`
    # ^^ create an endpoint at /api/v1/examples/:id which routes to the show action on ExamplesController
    # NB: be sure to define a controller action by adding a controller or using the 'extend_class' option!
    def self.use_routes(&block)
      @@actions.add(proc { Rails.application.routes.prepend(&block) })
    end

    # Extend an existing ruby class
    # example usage: `extend_class("Status") { def hello!; puts "Hi!"; end }`
    # ^^ define a new method 'hello!' which can be called on the existing Status class
    # NB: Be sure you know what you're doing here! For some tips on how to effectively overwrite ruby methods,
    #     check out this post: https://meta.discourse.org/t/tips-for-overriding-existing-discourse-methods-in-plugins/83389
    def self.extend_class(const, &block)
      @@actions.add(proc { const.constantize.class_eval(&block) })
    end

    # Add a new fabricator for testing
    # example usage: `use_fabricator(:example) { title { "Example!" } }`
    # ^^ create a new fabricator for the Example class
    # NB: Yes, you should be writing tests for your plugins ;)
    def self.use_fabricator(name, &block)
      @@actions.add(proc { Fabricator(name, &block) }) unless Rails.env.test?
    end
  end
end

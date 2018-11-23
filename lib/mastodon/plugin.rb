# frozen_string_literal: true

module Mastodon
  class Plugin
    NamedPath = Struct.new(:name, :path, :type)

    @@actions = Set.new
    @@paths   = Set.new
    @@assets  = Set.new

    cattr_accessor :actions
    cattr_accessor :paths
    cattr_accessor :assets

    private

    def self.use_classes
      @@actions.add(proc { Rails.application.paths.add relative_path_prefix, eager_load: true })
    end

    def self.use_assets
      use_directory('assets', '{js,scss,jpg,jpeg,png,svg}') { |asset| assets.add(asset) }
    end

    # Add translation overrides
    # example usage: `use_translations("locales")`
    # ^^ search for all .js files (for example en.js) for translation overrides in the
    # NB: The translation files take the following format:
    # module.exports = {
    #   "<translation_key>": "overriding value"
    # }
    def self.use_translations(path = 'locales')
      use_directory('locales', 'js') do |p|
        @@paths.add NamedPath.new(
          p.split('/').last.gsub('.js', ''),
          relative_path_prefix(p),
          :locale
        )
      end
    end

    def self.use_outlet(path, outlet)
      paths.add NamedPath.new(outlet, relative_path_prefix(path), :outlet)
    end

    # Add an api route
    # example usage: `use_route(:get, "examples/:id", "examples#show")`
    # ^^ create an endpoint at /api/v1/examples/:id which routes to the show action on ExamplesController
    # NB: be sure to define a controller action by adding a controller or using the 'extend_class' option!
    def self.use_routes(&block)
      actions.add(proc { Rails.application.routes.prepend(&block) })
    end

    # Extend an existing ruby class
    # example usage: `extend_class("Status") { def hello!; puts "Hi!"; end }`
    # ^^ define a new method 'hello!' which can be called on the existing Status class
    # NB: Be sure you know what you're doing here! For some tips on how to effectively overwrite ruby methods,
    #     check out this post: https://meta.discourse.org/t/tips-for-overriding-existing-discourse-methods-in-plugins/83389
    def self.extend_class(const, &block)
      actions.add(proc { const.constantize.class_eval(&block) })
    end

    # Add a new fabricator for testing
    # example usage: `use_fabricator(:example) { title { "Example!" } }`
    # ^^ create a new fabricator for the Example class
    # NB: Yes, you should be writing tests for your plugins ;)
    def self.use_fabricator(name, &block)
      actions.add(proc { Fabricator(name, &block) }) unless Rails.env.test?
    end

    def self.path_prefix(path = '')
      "#{Dir.pwd}/#{path}"
    end

    def self.relative_path_prefix(path = '')
      path_prefix(path).gsub(Rails.root.join('').to_s, '').delete_suffix('/').delete_prefix('/')
    end

    def self.use_directory(glob, ext)
      Dir.chdir(path_prefix) { Dir.glob("#{glob}/*.#{ext}").each { |path| yield path } }
    end
  end
end

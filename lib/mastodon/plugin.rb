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

    def self.use_asset(path, outlet: nil)
      path = path_prefix(path, relative: true)
      assets.add path
      paths.add NamedPath.new(outlet, path, :outlet) if outlet
    end

    def self.use_asset_directory(glob)
      use_directory(glob) { |path| use_asset(path) }
    end

    def self.use_class(path)
      actions.add(proc { require path_prefix path })
    end

    def self.use_class_directory(glob)
      use_directory(glob) { |path| use_class(path) }
    end

    # Add translation overrides
    # example usage: `use_translations("locales")`
    # ^^ search for all .js files (for example en.js) for translation overrides in the
    # NB: The translation files take the following format:
    # module.exports = {
    #   "<translation_key>": "overriding value"
    # }
    def self.use_translations(path)
      use_directory(path) do |p|
        @@paths.add NamedPath.new(
          p.split('/').last.gsub('.js', ''),
          path_prefix(p, relative: true),
          :locale
        )
      end
    end

    # Add an api route
    # example usage: `use_route(:get, "examples/:id", "examples#show")`
    # ^^ create an endpoint at /api/v1/examples/:id which routes to the show action on ExamplesController
    # NB: be sure to define a controller action by adding a controller or using the 'extend_class' option!
    def self.use_route(&block)
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

    # Add a new table to the database
    # example usage: `use_database_table(:examples) { |t| t.string :title }`
    # ^^ create a new 'examples' table in the database which has timestamps
    # NB: the block here is passed to create_table in a normal migration,
    #     so you can use anything that create_table will accept here.
    def self.use_database_table(table_name, &block)
      return if ActiveRecord::Base.connection.table_exists?(table_name)

      migration = ActiveRecord::Migration.new
      def migration.up(table_name, &block)
        create_table table_name.to_s.pluralize, &block
      end
      migration.up(table_name, &block)
    end

    # Add a new fabricator for testing
    # example usage: `use_fabricator(:example) { title { "Example!" } }`
    # ^^ create a new fabricator for the Example class
    # NB: Yes, you should be writing tests for your plugins ;)
    def self.use_fabricator(name, &block)
      actions.add(proc { Fabricator(name, &block) }) unless Rails.env.test?
    end

    def self.path_prefix(path = nil, relative: false)
      result = "#{Dir.pwd}/#{path}"
      result = result.gsub(Rails.root.join('').to_s, '') if relative
      result
    end

    def self.use_directory(glob)
      Dir.chdir(path_prefix) { Dir.glob("#{glob}/*.*").each { |path| yield path } }
    end
  end
end

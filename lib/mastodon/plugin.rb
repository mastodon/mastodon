module Mastodon
  class Plugin
    class NoCodeSpecifiedError < Exception; end
    class InvalidAssetType < Exception; end
    Outlet = Struct.new(:name, :component, :props)

    attr_accessor :name
    attr_reader :assets, :actions, :outlets

    def initialize
      @root = Dir.pwd
      @assets, @actions, @outlets = Set.new, Set.new, Set.new
    end

    # defined by the plugin
    def setup!
      raise NotImplementedError.new
    end

    private

    # Add translation files
    # example usage: `plugin.use_translations("locales")`
    # ^^ look in /plugins/example/locales and add the translations in `{locale}.json`
    # NB: these keys will take precedence over the ones in the core app
    def use_translations(path)
      raise NoCodeSpecifiedError.new unless path
      Rails.application.config.i18n.load_path += Dir[path_prefix "#{path}/*.yml"]
    end

    # Add an api route
    # This will add a line in the routes.rb file to the api namespace to allow for custom API endpoints
    # example usage: `plugin.use_route(:get, "examples/:id", "examples#show")`
    # ^^ create an endpoint at /api/v1/examples/:id which routes to the show action on ExamplesController
    # NB: be sure to define a controller action using the 'use_class' or 'extend_class' option!
    def use_route(verb, route, action)
      @actions.add Proc.new {
        Rails.application.routes.prepend do
          namespace(:api, path: 'api/v1', defaults: {format: :json}) { send(verb, { route => action }) }
        end
      }.to_proc
    end

    # Add an asset
    # example usage: `plugin.use_asset("components/example.js")`
    # ^^ load the file at /plugins/example/components/example.js into the asset pipeline
    # NB: you can load both javascript and scss files in this way
    def use_asset(path)
      raise InvalidAssetType.new unless [:scss, :js].include? path.split('.').last.to_sym
      @assets.add path_prefix(path, rails_root: false)
    end

    # Add a directory of assets
    # example usage: `plugin.use_asset_directory("components")`
    # ^^ load all js / scss files in the /plugins/example/components folder into the asset pipeline
    def use_asset_directory(glob)
      use_directory(glob) { |path| use_asset(path) }
    end

    # Apply a component to an outlet
    # example usage: `plugin.use_outlet("after-header", "ExampleComponent", { name: 'name' })`
    # ^^ in the after-header outlet in the interface, render <ExampleComponent name=name />
    # NB: You may need to PR an outlet to the core repo if one doesn't exist yet
    def use_outlet(outlet, component, props = {})
      @outlets.add Outlet.new(outlet, component, props)
    end

    # Create a new ruby class
    # example usage: plugin.use_class("models/example")`
    # ^^ run the code defined in /plugins/example/models/example.rb
    # NB: You want use this only to define entirely new classes, use 'extend_class' to override existing functionality
    def use_class(path)
      @actions.add Proc.new { require path_prefix path }.to_proc
    end

    # Extend an existing ruby class
    # example usage: `plugin.extend_class("Status") { def hello!; puts "Hi!"; end }`
    # ^^ define a new method 'hello!' which can be called on the existing Status class
    # NB: Be sure you know what you're doing here! For some tips on how to effectively overwrite ruby methods,
    #     check out this post: https://meta.discourse.org/t/tips-for-overriding-existing-discourse-methods-in-plugins/83389
    def extend_class(const, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      @actions.add Proc.new { const.constantize.class_eval(&block) }.to_proc
    end

    # Add a directory of classes
    # example usage: `plugin.use_class_directory("models")`
    # ^^ load all ruby classes defined in files in the /plugins/example/models folder
    def use_class_directory(glob)
      use_directory(glob) { |path| use_class(path) }
    end

    # Add a new table to the database
    # example usage: `plugin.use_database_table(:examples) { |t| t.string :title }`
    # ^^ create a new 'examples' table in the database which has timestamps
    # NB: the block here is passed to create_table in a normal migration,
    #     so you can use anything that create_table will accept here.
    def use_database_table(table_name, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      return if ActiveRecord::Base.connection.table_exists?(table_name)
      puts "Adding #{table_name} for plugin #{name}..."

      migration = ActiveRecord::Migration.new
      def migration.up(table_name, &block)
        create_table table_name.to_s.pluralize, &block
      end
      migration.up(table_name, &block)
    end

    # Add a new fabricator for testing
    # example usage: `plugin.use_fabricator(:example) { title { "Example!" } }`
    # ^^ create a new fabricator for the Example class defined using use_class
    # NB: Yes, you should be writing tests for your plugins ;)
    def use_fabricator(name, &block)
      return unless Rails.env.test?
      raise NoCodeSpecifiedError.new unless block_given?
      @actions.add Proc.new { Fabricator(name, &block) }.to_proc
    end

    def path_prefix(path = nil, rails_root: true)
      path = [@root, path].compact.join('/')
      path = path.sub("#{Rails.root}/", '') unless rails_root
      path
    end

    def use_directory(glob)
      Dir.chdir(path_prefix) { Dir.glob("#{glob}/*.*").each { |path| yield path } }
    end
  end
end

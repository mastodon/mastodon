# cherry picking active_support stuff
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/attribute_accessors'

require 'simple_navigation/version'
require 'simple_navigation/configuration'
require 'simple_navigation/item_adapter'
require 'simple_navigation/item'
require 'simple_navigation/item_container'
require 'simple_navigation/items_provider'
require 'simple_navigation/renderer'
require 'simple_navigation/adapters'
require 'simple_navigation/config_file_finder'
require 'simple_navigation/railtie' if defined?(::Rails::Railtie)

require 'forwardable'

# A plugin for generating a simple navigation. See README for resources on
# usage instructions.
module SimpleNavigation
  mattr_accessor :adapter,
                 :adapter_class,
                 :config_files,
                 :config_file_paths,
                 :default_renderer,
                 :environment,
                 :registered_renderers,
                 :root

  # Cache for loaded config files
  self.config_files = {}

  # Allows for multiple config_file_paths. Needed if a plugin itself uses
  # simple-navigation and therefore has its own config file
  self.config_file_paths = []

  # Maps renderer keys to classes. The keys serve as shortcut in the
  # render_navigation calls (renderer: :list)
  self.registered_renderers = {
    list:        SimpleNavigation::Renderer::List,
    links:       SimpleNavigation::Renderer::Links,
    breadcrumbs: SimpleNavigation::Renderer::Breadcrumbs,
    text:        SimpleNavigation::Renderer::Text,
    json:        SimpleNavigation::Renderer::Json
  }

  class << self
    extend Forwardable

    def_delegators :adapter, :context_for_eval,
                             :current_page?,
                             :request,
                             :request_path,
                             :request_uri

    def_delegators :adapter_class, :register

    # Sets the root path and current environment as specified. Also sets the
    # default config_file_path.
    def set_env(root, environment)
      self.root = root
      self.environment = environment
      config_file_paths << default_config_file_path
    end

    # Returns the current framework in which the plugin is running.
    def framework
      return :rails if defined?(Rails)
      return :padrino if defined?(Padrino)
      return :sinatra if defined?(Sinatra)
      return :nanoc if defined?(Nanoc3)
      fail 'simple_navigation currently only works for Rails, Sinatra and ' \
           'Padrino apps'
    end

    # Loads the adapter for the current framework
    def load_adapter
      self.adapter_class =
        case framework
        when :rails then SimpleNavigation::Adapters::Rails
        when :sinatra then SimpleNavigation::Adapters::Sinatra
        when :padrino then SimpleNavigation::Adapters::Padrino
        when :nanoc then SimpleNavigation::Adapters::Nanoc
        end
    end

    # Creates a new adapter instance based on the context in which
    # render_navigation has been called.
    def init_adapter_from(context)
      self.adapter = adapter_class.new(context)
    end

    def default_config_file_path
      File.join(root, 'config')
    end

    # Resets the list of config_file_paths to the specified path
    def config_file_path=(path)
      self.config_file_paths = [path]
    end

    # Reads the config_file for the specified navigation_context and stores it
    # for later evaluation.
    def load_config(navigation_context = :default)
      if environment == 'production'
        update_config(navigation_context)
      else
        update_config!(navigation_context)
      end
    end

    # Returns the singleton instance of the SimpleNavigation::Configuration
    def config
      SimpleNavigation::Configuration.instance
    end

    # Returns the ItemContainer that contains the items for the
    # primary navigation
    def primary_navigation
      config.primary_navigation
    end

    # Returns the active item container for the specified level.
    # Valid levels are
    # * :all - in this case the primary_navigation is returned.
    # * :leaves - the 'deepest' active item_container will be returned
    # * a specific level - the active item_container for the specified level
    #   will be returned
    # * a range of levels - the active item_container for the range's minimum
    #   will be returned
    #
    # Returns nil if there is no active item_container for the specified level.
    def active_item_container_for(level)
      case level
      when :all then primary_navigation
      when :leaves then primary_navigation.active_leaf_container
      when Integer then primary_navigation.active_item_container_for(level)
      when Range then primary_navigation.active_item_container_for(level.min)
      else
        fail ArgumentError, "Invalid navigation level: #{level}"
      end
    end

    # Registers a renderer.
    #
    # === Example
    # To register your own renderer:
    #
    #   SimpleNavigation.register_renderer my_renderer: My::RendererClass
    #
    # Then in the view you can call:
    #
    #   render_navigation(renderer: :my_renderer)
    def register_renderer(renderer_hash)
      registered_renderers.merge!(renderer_hash)
    end

    private

    def config_file(navigation_context)
      ConfigFileFinder.new(config_file_paths).find(navigation_context)
    end

    def read_config(navigation_context)
      File.read config_file(navigation_context)
    end

    def update_config(navigation_context)
      config_files[navigation_context] ||= read_config(navigation_context)
    end

    def update_config!(navigation_context)
      config_files[navigation_context] = read_config(navigation_context)
    end
  end
end

SimpleNavigation.load_adapter

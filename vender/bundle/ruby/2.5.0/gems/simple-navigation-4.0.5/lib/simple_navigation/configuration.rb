require 'singleton'

module SimpleNavigation
  # Responsible for evaluating and handling the config/navigation.rb file.
  class Configuration
    include Singleton

    attr_accessor :autogenerate_item_ids,
                  :auto_highlight,
                  :consider_item_names_as_safe,
                  :highlight_on_subpath,
                  :ignore_query_params_on_auto_highlight,
                  :ignore_anchors_on_auto_highlight

    attr_reader :primary_navigation

    attr_writer :active_leaf_class,
                :id_generator,
                :name_generator,
                :renderer,
                :selected_class

    # Evals the config_file for the given navigation_context
    def self.eval_config(navigation_context = :default)
      context = SimpleNavigation.config_files[navigation_context]
      SimpleNavigation.context_for_eval.instance_eval(context)
    end

    # Starts processing the configuration
    def self.run(&block)
      block.call Configuration.instance
    end

    # Sets the config's default-settings
    def initialize
      @autogenerate_item_ids = true
      @auto_highlight = true
      @consider_item_names_as_safe = false
      @highlight_on_subpath = false
      @ignore_anchors_on_auto_highlight = true
      @ignore_query_params_on_auto_highlight = true
    end

    def active_leaf_class
      @active_leaf_class ||= 'simple-navigation-active-leaf'
    end

    def id_generator
      @id_generator ||= :to_s.to_proc
    end

    # This is the main method for specifying the navigation items.
    # It can be used in two ways:
    #
    # 1. Declaratively specify your items in the config/navigation.rb file
    #    using a block. It then yields an SimpleNavigation::ItemContainer
    #    for adding navigation items.
    # 2. Directly provide your items to the method (e.g. when loading your
    #    items from the database).
    #
    # ==== Example for block style (configuration file)
    #   config.items do |primary|
    #     primary.item :my_item, 'My item', my_item_path
    #     ...
    #   end
    #
    # ==== To consider when directly providing items
    # items_provider should be:
    # * a methodname (as symbol) that returns your items. The method needs to
    #   be available in the view (i.e. a helper method)
    # * an object that responds to :items
    # * an enumerable containing your items
    # The items you specify have to fullfill certain requirements.
    # See SimpleNavigation::ItemAdapter for more details.
    #
    def items(items_provider = nil, &block)
      if (items_provider && block) || (items_provider.nil? && block.nil?)
        fail('please specify either items_provider or block, but not both')
      end

      self.primary_navigation = ItemContainer.new

      if block
        block.call primary_navigation
      else
        primary_navigation.items = ItemsProvider.new(items_provider).items
      end
    end

    # Returns true if the config_file has already been evaluated.
    def loaded?
      !primary_navigation.nil?
    end

    def name_generator
      @name_generator ||= proc { |name| name }
    end

    def renderer
      @renderer ||= SimpleNavigation.default_renderer ||
                    SimpleNavigation::Renderer::List
    end

    def selected_class
      @selected_class ||= 'selected'
    end

    private

    attr_writer :primary_navigation
  end
end

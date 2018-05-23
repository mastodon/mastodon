module SimpleNavigation
  # View helpers to render the navigation.
  #
  # Use render_navigation as following to render your navigation:
  # * call <tt>render_navigation</tt> without :level option to render your
  #   complete navigation as nested tree.
  # * call <tt>render_navigation(level: x)</tt> to render a specific
  #   navigation level (e.g. level: 1 to render your primary navigation,
  #   level: 2 to render the sub navigation and so forth)
  # * call <tt>render_navigation(:level => 2..3)</tt> to render navigation
  #   levels 2 and 3).
  #
  # For example, you could use render_navigation(level: 1) to render your
  # primary navigation as tabs and render_navigation(level: 2..3) to render
  # the rest of the navigation as a tree in a sidebar.
  #
  # ==== Examples (using Haml)
  #   #primary_navigation= render_navigation(level: 1)
  #
  #   #sub_navigation= render_navigation(level: 2)
  #
  #   #nested_navigation= render_navigation
  #
  #   #top_navigation= render_navigation(level: 1..2)
  #   #sidebar_navigation= render_navigation(level: 3)
  module Helpers
    def self.load_config(options, includer, &block)
      context = options.delete(:context)
      SimpleNavigation.init_adapter_from includer
      SimpleNavigation.load_config context
      SimpleNavigation::Configuration.eval_config context

      if block_given? || options[:items]
        SimpleNavigation.config.items(options[:items], &block)
      end

      unless SimpleNavigation.primary_navigation
        fail 'no primary navigation defined, either use a navigation config ' \
             'file or pass items directly to render_navigation'
      end
    end

    def self.apply_defaults(options)
      options[:level] = options.delete(:levels) if options[:levels]
      { context: :default, level: :all }.merge(options)
    end

    # Renders the navigation according to the specified options-hash.
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :all which renders the the sub_navigation
    #   for an active primary_navigation inside that active
    #   primary_navigation item.
    #   Specify a specific level to only render that level of navigation
    #   (e.g. level: 1 for primary_navigation, etc).
    #   Specifiy a Range of levels to render only those specific levels
    #   (e.g. level: 1..2 to render both your first and second levels, maybe
    #   you want to render your third level somewhere else on the page)
    # * <tt>:expand_all</tt> - defaults to false. If set to true the all
    #   specified levels will be rendered as a fully expanded
    #   tree (always open). This is useful for javascript menus like Superfish.
    # * <tt>:context</tt> - specifies the context for which you would render
    #   the navigation. Defaults to :default which loads the default
    #   navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration
    #   file for that context, e.g. if you call
    #   <tt>render_navigation(context: :admin)</tt> the file
    #   config/admin_navigation.rb will be loaded and used for rendering
    #   the navigation.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are
    #   dynamically generated from database).
    #   See SimpleNavigation::ItemsProvider for documentation on what to
    #   provide as items.
    # * <tt>:renderer</tt> - specify the renderer to be used for rendering the
    #   navigation. Either provide the Class or a symbol matching a registered
    #   renderer. Defaults to :list (html list renderer).
    #
    # Instead of using the <tt>:items</tt> option, a block can be passed to
    # specify the items dynamically
    #
    # ==== Examples
    #   render_navigation do |menu|
    #     menu.item :posts, "Posts", posts_path
    #   end
    #
    def render_navigation(options = {}, &block)
      container = active_navigation_item_container(options, &block)
      container && container.render(options)
    end

    # Returns the name of the currently active navigation item belonging to the
    # specified level.
    #
    # See Helpers#active_navigation_item for supported options.
    #
    # Returns an empty string if no active item can be found for the specified
    # options
    def active_navigation_item_name(options = {})
      active_navigation_item(options, '') do |item|
        item.name(apply_generator: false)
      end
    end

    # Returns the key of the currently active navigation item belonging to the
    # specified level.
    #
    # See Helpers#active_navigation_item for supported options.
    #
    # Returns <tt>nil</tt> if no active item can be found for the specified
    # options
    def active_navigation_item_key(options = {})
      active_navigation_item(options, &:key)
    end

    # Returns the currently active navigation item belonging to the specified
    # level.
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :all which returns the
    #   most specific/deepest selected item (the leaf).
    #   Specify a specific level to only look for the selected item in the
    #   specified level of navigation
    #   (e.g. level: 1 for primary_navigation, etc).
    # * <tt>:context</tt> - specifies the context for which you would like to
    #   find the active navigation item. Defaults to :default which loads the
    #   default navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration
    #   file for that context, e.g. if you call
    #   <tt>active_navigation_item_name(context: :admin)</tt> the file
    #   config/admin_navigation.rb will be loaded and used for searching the
    #   active item.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are
    #   dynamically generated from database).
    #   See SimpleNavigation::ItemsProvider for documentation on what to provide
    #   as items.
    #
    # Returns the supplied <tt>value_for_nil</tt> object (<tt>nil</tt>
    # by default) if no active item can be found for the specified
    # options
    def active_navigation_item(options = {}, value_for_nil = nil)
      if options[:level].nil? || options[:level] == :all
        options[:level] = :leaves
      end
      container = active_navigation_item_container(options)
      if container && (item = container.selected_item)
        block_given? ? yield(item) : item
      else
        value_for_nil
      end
    end

    # Returns the currently active item container belonging to the specified
    # level.
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :all which returns the
    #   least specific/shallowest selected item.
    #   Specify a specific level to only look for the selected item in the
    #   specified level of navigation
    #   (e.g. level: 1 for primary_navigation, etc).
    # * <tt>:context</tt> - specifies the context for which you would like to
    #   find the active navigation item. Defaults to :default which loads the
    #   default navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration
    #   file for that context, e.g. if you call
    #   <tt>active_navigation_item_name(context: :admin)</tt> the file
    #   config/admin_navigation.rb will be loaded and used for searching the
    #   active item.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are
    #   dynamically generated from database).
    #   See SimpleNavigation::ItemsProvider for documentation on what to provide
    #   as items.
    #
    # Returns <tt>nil</tt> if no active item container can be found
    def active_navigation_item_container(options = {}, &block)
      options = SimpleNavigation::Helpers.apply_defaults(options)
      SimpleNavigation::Helpers.load_config(options, self, &block)
      SimpleNavigation.active_item_container_for(options[:level])
    end
  end
end

module SimpleNavigation
  # Holds the Items for a navigation 'level'.
  class ItemContainer
    attr_accessor :auto_highlight,
                  :dom_class,
                  :dom_id,
                  :renderer,
                  :selected_class

    attr_reader :items, :level

    attr_writer :dom_attributes

    def initialize(level = 1) #:nodoc:
      @level = level
      @items ||= []
      @renderer = SimpleNavigation.config.renderer
      @auto_highlight = true
    end

    def dom_attributes
      # backward compability for #dom_id and #dom_class
      dom_id_and_class = {
        id: dom_id,
        class: dom_class
      }.reject { |_, v| v.nil? }
      (@dom_attributes || {}).merge(dom_id_and_class)
    end

    # Creates a new navigation item.
    #
    # The <tt>key</tt> is a symbol which uniquely defines your navigation item
    # in the scope of the primary_navigation or the sub_navigation.
    #
    # The <tt>name</tt> will be displayed in the rendered navigation.
    # This can also be a call to your I18n-framework.
    #
    # The <tt>url</tt> is the address that the generated item points to.
    # You can also use url_helpers (named routes, restful routes helper,
    # url_for, etc). <tt>url</tt> is optional - items without URLs should not
    # be rendered as links.
    #
    # The <tt>options</tt> can be used to specify the following things:
    # * <tt>any html_attributes</tt> - will be included in the rendered
    #   navigation item (e.g. id, class etc.)
    # * <tt>:if</tt> - Specifies a proc to call to determine if the item should
    #   be rendered (e.g. <tt>if: Proc.new { current_user.admin? }</tt>). The
    #   proc should evaluate to a true or false value and is evaluated
    #   in the context of the view.
    # * <tt>:unless</tt> - Specifies a proc to call to determine if the item
    #   should not be rendered
    #   (e.g. <tt>unless: Proc.new { current_user.admin? }</tt>).
    #   The proc should evaluate to a true or false value and is evaluated in
    #   the context of the view.
    # * <tt>:method</tt> - Specifies the http-method for the generated link -
    #   default is :get.
    # * <tt>:highlights_on</tt> - if autohighlighting is turned off and/or you
    #   want to explicitly specify when the item should be highlighted, you can
    #   set a regexp which is matched againstthe current URI.
    #
    # The <tt>block</tt> - if specified - will hold the item's sub_navigation.
    def item(key, name, url = nil, options = {}, &block)
      return unless should_add_item?(options)
      item = Item.new(self, key, name, url, options, &block)
      add_item item, options
    end

    def items=(new_items)
      new_items.each do |item|
        item_adapter = ItemAdapter.new(item)
        next unless should_add_item?(item_adapter.options)
        add_item item_adapter.to_simple_navigation_item(self), item_adapter.options
      end
    end

    # Returns the Item with the specified key, nil otherwise.
    #
    def [](navi_key)
      items.find { |item| item.key == navi_key }
    end

    # Returns the level of the item specified by navi_key.
    # Recursively works its way down the item's sub_navigations if the desired
    # item is not found directly in this container's items.
    # Returns nil if item cannot be found.
    #
    def level_for_item(navi_key)
      return level if self[navi_key]

      items.each do |item|
        next unless item.sub_navigation
        level = item.sub_navigation.level_for_item(navi_key)
        return level if level
      end
      return nil
    end

    # Renders the items in this ItemContainer using the configured renderer.
    #
    # The options are the same as in the view's render_navigation call
    # (they get passed on)
    def render(options = {})
      renderer_instance(options).render(self)
    end

    # Returns true if any of this container's items is selected.
    #
    def selected?
      items.any?(&:selected?)
    end

    # Returns the currently selected item, nil if no item is selected.
    #
    def selected_item
      items.find(&:selected?)
    end

    # Returns the active item_container for the specified level
    # (recursively looks up items in selected sub_navigation if level is deeper
    # than this container's level).
    def active_item_container_for(desired_level)
      if level == desired_level
        self
      elsif selected_sub_navigation?
        selected_item.sub_navigation.active_item_container_for(desired_level)
      end
    end

    # Returns the deepest possible active item_container.
    # (recursively searches in the sub_navigation if this container has a
    # selected sub_navigation).
    def active_leaf_container
      if selected_sub_navigation?
        selected_item.sub_navigation.active_leaf_container
      else
        self
      end
    end

    # Returns true if there are no items defined for this container.
    def empty?
      items.empty?
    end

    private

    def add_item(item, options)
      items << item
      modify_dom_attributes(options)
    end

    def modify_dom_attributes(options)
      return unless container_options = options[:container]
      self.dom_attributes = container_options.fetch(:attributes) { dom_attributes }
      self.dom_class = container_options.fetch(:class) { dom_class }
      self.dom_id = container_options.fetch(:id) { dom_id }
      self.selected_class = container_options.fetch(:selected_class) { selected_class }
    end

    # FIXME: raise an exception if :rederer is a symbol and it is not registred
    #        in SimpleNavigation.registered_renderers
    def renderer_instance(options)
      return renderer.new(options) unless options[:renderer]

      if options[:renderer].is_a?(Symbol)
        registered_renderer = SimpleNavigation.registered_renderers[options[:renderer]]
        registered_renderer.new(options)
      else
        options[:renderer].new(options)
      end
    end

    def selected_sub_navigation?
      !!(selected_item && selected_item.sub_navigation)
    end

    def should_add_item?(options)
      [options[:if]].flatten.compact.all? { |m| evaluate_method(m) } &&
      [options[:unless]].flatten.compact.none? { |m| evaluate_method(m) }
    end

    def evaluate_method(method)
      case method
      when Proc, Method then method.call
      else fail(ArgumentError, ':if or :unless must be procs or lambdas')
      end
    end
  end
end

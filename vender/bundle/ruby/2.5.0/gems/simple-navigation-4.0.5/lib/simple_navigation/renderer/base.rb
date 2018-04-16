require 'forwardable'

module SimpleNavigation
  module Renderer
    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer and its
    # containing items to HTML.
    class Base
      extend Forwardable

      attr_reader :adapter, :options

      def_delegators :adapter, :link_to, :content_tag

      def initialize(options) #:nodoc:
        @options = options
        @adapter = SimpleNavigation.adapter
      end

      def expand_all?
        !!options[:expand_all]
      end

      def level
        options[:level] || :all
      end

      def skip_if_empty?
        !!options[:skip_if_empty]
      end

      def include_sub_navigation?(item)
        consider_sub_navigation?(item) && expand_sub_navigation?(item)
      end

      def render_sub_navigation_for(item)
        item.sub_navigation.render(options)
      end

      # Renders the specified ItemContainer to HTML.
      #
      # When implementing a renderer, please consider to call
      # include_sub_navigation? to determine whether an item's sub_navigation
      # should be rendered or not.
      def render(item_container)
        fail NotImplementedError, 'subclass responsibility'
      end

      protected

      def consider_sub_navigation?(item)
        return false unless item.sub_navigation

        case level
        when :all then true
        when Range then item.sub_navigation.level <= level.max
        else false
        end
      end

      def expand_sub_navigation?(item)
        expand_all? || item.selected?
      end

      # to allow overriding when there is specific logic determining
      # when a link should not be rendered (eg. breadcrumbs renderer
      # does not render the final breadcrumb as a link when instructed
      # not to do so.)
      def suppress_link?(item)
        item.url.nil?
      end

      # determine and return link or static content depending on
      # item/renderer conditions.
      def tag_for(item)
        if suppress_link?(item)
          content_tag('span', item.name, link_options_for(item).except(:method))
        else
          link_to(item.name, item.url, options_for(item))
        end
      end

      # to allow overriding when link options should be special-cased
      # (eg. links renderer uses item options for the a-tag rather
      # than an li-tag).
      def options_for(item)
        link_options_for(item)
      end

      # Extracts the options relevant for the generated link
      def link_options_for(item)
        special_options = {
          method: item.method,
          class: item.selected_class
        }.reject { |_, v| v.nil? }

        link_options = item.link_html_options

        return special_options unless link_options

        opts = special_options.merge(link_options)

        classes = [link_options[:class], item.selected_class]
        classes = classes.flatten.compact.join(' ')
        opts[:class] = classes unless classes.empty?

        opts
      end
    end
  end
end

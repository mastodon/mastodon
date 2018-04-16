module SimpleNavigation
  module Renderer
    # Renders an ItemContainer as a <div> element and its containing items as
    # <a> elements.
    # It only renders 'selected' elements.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered
    # <a> element unless the config option <tt>autogenerate_item_ids</tt> is
    # set to false.
    #
    # The id can also be explicitely specified by setting the id in the
    # html-options of the 'item' method in the config/navigation.rb file.
    # The ItemContainer's dom_attributes are applied to the surrounding <div>
    # element.
    class Breadcrumbs < SimpleNavigation::Renderer::Base
      def render(item_container)
        content = a_tags(item_container).join(join_with)
        content_tag(:div,
                    prefix_for(content) + content,
                    item_container.dom_attributes)
      end

      protected

      def a_tags(item_container)
        item_container.items.each_with_object([]) do |item, list|
          next unless item.selected?
          list << tag_for(item)

          if include_sub_navigation?(item)
            list.concat a_tags(item.sub_navigation)
          end
        end
      end

      def join_with
        @join_with ||= options[:join_with] || ' '
      end

      def suppress_link?(item)
        super || (options[:static_leaf] && item.active_leaf_class)
      end

      def prefix_for(content)
        if !content.empty? && options[:prefix]
          options[:prefix]
        else
          ''
        end
      end

      # Extracts the options relevant for the generated link
      #
      def link_options_for(item)
        if options[:allow_classes_and_ids]
          opts = super
          opts[:id] &&= "breadcrumb_#{opts[:id]}"
          opts
        else
          html_options = item.html_options.except(:class, :id)
          { method: item.method }.merge(html_options)
        end
      end
    end
  end
end

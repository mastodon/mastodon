module SimpleNavigation
  module Renderer
    # Renders the 'chain' of selected navigation items as simple text items,
    # joined with an optional separator (similar to breadcrumbs, but without
    # markup).
    class Text < SimpleNavigation::Renderer::Base
      def render(item_container)
        list(item_container).compact.join(options[:join_with] || ' ')
      end

      private

      def list(item_container)
        item_container.items.keep_if(&:selected?).map do |item|
          [item.name(apply_generator: false)] +
          (include_sub_navigation?(item) ? list(item.sub_navigation) : [])
        end
      end
    end
  end
end

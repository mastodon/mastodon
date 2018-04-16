require 'json'

module SimpleNavigation
  module Renderer
    # Renders the navigation items as a object tree serialized as a json string,
    # can also output raw ruby Hashes
    class Json < SimpleNavigation::Renderer::Base
      def render(item_container)
        results = hash_render(item_container)
        options[:as_hash] ? results : results.to_json
      end

      private

      def hash_render(item_container)
        return nil unless item_container

        item_container.items.map do |item|
          {
            items: hash_render(item.sub_navigation),
            name: item.name,
            selected: item.selected?,
            url: item.url
          }
        end
      end
    end
  end
end

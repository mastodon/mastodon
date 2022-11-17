# frozen_string_literal: true

module SimpleNavigation
  module ItemExtensions
    def url
      if @url.nil? && @sub_navigation
        @sub_navigation.items.first.url
      else
        @url
      end
    end
  end
end

SimpleNavigation::Item.prepend(SimpleNavigation::ItemExtensions)

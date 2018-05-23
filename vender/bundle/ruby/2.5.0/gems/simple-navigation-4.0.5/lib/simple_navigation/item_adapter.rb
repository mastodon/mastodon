require 'forwardable'
require 'ostruct'

module SimpleNavigation
  # This class acts as an adapter to items that are not defined using the DSL
  # in the config/navigation.rb, but directly provided inside the application.
  # When defining the items that way, every item you provide needs to define
  # the following methods:
  #
  # * <tt>key</tt>
  # * <tt>name</tt>
  # * <tt>url</tt>
  #
  # and optionally
  #
  # * <tt>options</tt>
  # * <tt>items</tt> - if one of your items has a subnavigation it must respond
  #                    to <tt>items</tt> providing the subnavigation.
  #
  # You can also specify your items as a list of hashes.
  # The hashes will be converted to objects automatically.
  # The hashes representing the items obviously must have the keys :key, :name
  # and :url and optionally the keys :options and :items.
  #
  # See SimpleNavigation::ItemContainer#item for the purpose of these methods.
  class ItemAdapter
    extend Forwardable

    def_delegators :item, :key, :name, :url

    attr_reader :item

    def initialize(item)
      @item = item.is_a?(Hash) ? OpenStruct.new(item) : item
    end

    # Returns the options for this item. If the wrapped item does not implement
    # an options method, an empty hash is returned.
    def options
      item.respond_to?(:options) ? item.options : {}
    end

    # Returns the items (subnavigation) for this item if it responds to :items
    # and the items-collection is not empty. Returns nil otherwise.
    def items
      item.items if item.respond_to?(:items) && item.items && item.items.any?
    end

    # Converts this Item into a SimpleNavigation::Item
    def to_simple_navigation_item(item_container)
      SimpleNavigation::Item.new(item_container, key, name, url, options)
    end
  end
end

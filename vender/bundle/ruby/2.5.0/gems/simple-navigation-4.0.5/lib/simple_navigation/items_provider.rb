module SimpleNavigation
  # Acts as a proxy to navigation items that are passed into the
  # SimpleNavigation::Configuration#items method.
  # It hides the logic for finding items from the Configuration object.
  #
  class ItemsProvider
    attr_reader :provider

    # It accepts the following types of provider:
    # * methodname as symbol - the specified method should return the relevant
    #   items and has to be available in the view (a helper method)
    # * object that responds to :items
    # * enumerable object that represents the items
    #
    # See SimpleNavigation::ItemAdapter for the requirements that need to be
    # fulfilled by the provided items.
    #
    def initialize(provider)
      @provider = provider
    end

    # Returns the navigation items
    def items
      if provider.is_a?(Symbol)
        SimpleNavigation.context_for_eval.send(provider)
      elsif provider.respond_to?(:items)
        provider.items
      elsif provider.respond_to?(:each)
        provider
      else
        fail('items_provider either must be a symbol specifying the '         \
             'helper-method to call, an object with an items-method defined ' \
             'or an enumerable representing the items')
      end
    end
  end
end

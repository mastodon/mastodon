module Responders
  # This responder modifies your current responder to redirect
  # to the collection page on POST/PUT/DELETE.
  module CollectionResponder
    protected

    # Returns the collection location for redirecting after POST/PUT/DELETE.
    # This method, converts the following resources array to the following:
    #
    #   [:admin, @post] #=> [:admin, :posts]
    #   [@user, @post]  #=> [@user, :posts]
    #
    # When these new arrays are given to redirect_to, it will generate the
    # proper URL pointing to the index action.
    #
    #   [:admin, @post] #=> admin_posts_url
    #   [@user, @post]  #=> user_posts_url(@user.to_param)
    #
    def navigation_location
      return options[:location] if options[:location]
      klass = resources.last.class

      if klass.respond_to?(:model_name)
        resources[0...-1] << klass.model_name.route_key.to_sym
      else
        resources
      end
    end
  end
end

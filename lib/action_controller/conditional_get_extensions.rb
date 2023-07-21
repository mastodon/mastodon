# frozen_string_literal: true

module ActionController
  module ConditionalGetExtensions
    def expires_in(*)
      # This backports a fix from Rails 7 so that a more private Cache-Control
      # can be overriden by calling expires_in on a specific controller action
      response.cache_control.delete(:no_store)

      super
    end
  end
end

ActionController::ConditionalGet.prepend(ActionController::ConditionalGetExtensions)

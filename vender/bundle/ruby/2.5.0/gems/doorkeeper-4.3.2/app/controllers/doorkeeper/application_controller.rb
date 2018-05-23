module Doorkeeper
  class ApplicationController <
    Doorkeeper.configuration.base_controller.constantize

    include Helpers::Controller

    protect_from_forgery with: :exception

    helper 'doorkeeper/dashboard'
  end
end

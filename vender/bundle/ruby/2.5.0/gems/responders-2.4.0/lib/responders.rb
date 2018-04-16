require 'action_controller'
require 'rails/railtie'

module ActionController
  autoload :Responder, 'action_controller/responder'
  autoload :RespondWith, 'action_controller/respond_with'
end

module Responders
  autoload :FlashResponder,      'responders/flash_responder'
  autoload :HttpCacheResponder,  'responders/http_cache_responder'
  autoload :CollectionResponder, 'responders/collection_responder'
  autoload :LocationResponder,   'responders/location_responder'

  require 'responders/controller_method'

  class Railtie < ::Rails::Railtie
    config.responders = ActiveSupport::OrderedOptions.new
    config.responders.flash_keys = [:notice, :alert]
    config.responders.namespace_lookup = false

    # Add load paths straight to I18n, so engines and application can overwrite it.
    require 'active_support/i18n'
    I18n.load_path << File.expand_path('../responders/locales/en.yml', __FILE__)

    initializer "responders.flash_responder" do |app|
      Responders::FlashResponder.flash_keys = app.config.responders.flash_keys
      Responders::FlashResponder.namespace_lookup = app.config.responders.namespace_lookup
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include ActionController::RespondWith
end

require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module Lograge
  class Railtie < Rails::Railtie
    config.lograge = Lograge::OrderedOptions.new
    config.lograge.enabled = false

    config.after_initialize do |app|
      Lograge.setup(app) if app.config.lograge.enabled
    end
  end
end

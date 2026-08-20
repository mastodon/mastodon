# frozen_string_literal: true

require 'vite'

Vite.setup do |config|
  config.copy_from Rails.application.config_for(:vite)
  config.logger = Rails.logger.tagged('vite')

  if Rails.env.development?
    Rails.application.config.middleware.insert_before(0, Vite::Proxy, config:, dev_server: Vite.dev_server)
  else
    Rails.application.config.to_prepare do
      Vite.preload if defined?(Rails::Server) || defined?(Rails::Console)
    end
  end
end

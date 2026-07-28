# frozen_string_literal: true

require 'vite'

Vite.setup do |config|
  config.copy_from Rails.application.config_for(:vite)

  if Rails.env.development?
    Rails.application.config.middleware.insert_before(0, Vite::Proxy, config)
  else
    Rails.application.config.to_prepare do
      Vite.preload
    end
  end
end

# frozen_string_literal: true

require 'vite'

Vite.setup do |config|
  if Rails.env.development?
    config.tag_strategies = [:dev_server, :manifest]
    Rails.application.config.middleware.insert_before(0, Vite::Proxy, config)
  else
    config.tag_strategies = [:manifest]
  end
end

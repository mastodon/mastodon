# frozen_string_literal: true

require 'vite'

Vite.setup do |config|
  if Rails.env.development?
    config.tag_strategies = [:dev_server, :manifest]
    # config.tag_strategies = [:manifest]

    # TODO: Only on prod
    Rails.application.config.to_prepare do
      Vite.preload
    end
    Rails.application.config.middleware.insert_before(0, Vite::Proxy, config)
  else
    config.tag_strategies = [:manifest]
  end
end

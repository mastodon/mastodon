# frozen_string_literal: true

Rails.application.configure do
  config.x.cache_buster_enabled = ENV['CACHE_BUSTER_ENABLED'] == 'true'

  config.x.cache_buster = {
    secret_header: ENV['CACHE_BUSTER_SECRET_HEADER'],
    secret: ENV['CACHE_BUSTER_SECRET'],
  }
end

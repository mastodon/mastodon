# frozen_string_literal: true

require 'vite'

Vite.setup do |config|
  Rails.application.config.middleware.insert_before(0, Vite::Proxy, config) if Rails.env.development?
end

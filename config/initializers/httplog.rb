# frozen_string_literal: true

# Disable httplog in production unless log_level is `debug`
if !Rails.env.production? || Rails.configuration.log_level == :debug
  require 'httplog'

  HttpLog.configure do |config|
    config.logger = Rails.logger
    config.color = { color: :yellow }
    config.compact_log = true
  end
end

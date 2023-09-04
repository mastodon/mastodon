# frozen_string_literal: true

HttpLog.configure do |config|
  config.logger = Rails.logger
  config.color = { color: :yellow }
  config.compact_log = true
end

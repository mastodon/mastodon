# frozen_string_literal: true

Rails.application.configure do
  config.x.whitelist_mode = ENV['WHITELIST_MODE'] == 'true'
end

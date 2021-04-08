# frozen_string_literal: true

Rails.application.configure do
  config.x.whitelist_mode = (ENV['LIMITED_FEDERATION_MODE'] || ENV['WHITELIST_MODE']) == 'true'
end

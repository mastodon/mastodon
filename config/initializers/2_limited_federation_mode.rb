# frozen_string_literal: true

Rails.application.configure do
  config.x.limited_federation_mode = (ENV['LIMITED_FEDERATION_MODE'] || ENV['WHITELIST_MODE']) == 'true'

  warn 'WARN: The environment variable WHITELIST_MODE has been replaced with LIMITED_FEDERATION_MODE, you should rename this environment variable in your configuration.' if ENV.key?('WHITELIST_MODE')
end

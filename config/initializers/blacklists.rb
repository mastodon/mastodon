# frozen_string_literal: true

Rails.application.configure do
  config.x.email_domains_blacklist = ENV.fetch('EMAIL_DOMAIN_BLACKLIST') { 'mvrht.com' }
  config.x.email_domains_whitelist = ENV.fetch('EMAIL_DOMAIN_WHITELIST') { '' }
end

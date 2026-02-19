# frozen_string_literal: true

Rails.application.configure do
  config.x.email_domains_denylist = ENV.fetch('EMAIL_DOMAIN_DENYLIST', nil) || ENV.fetch('EMAIL_DOMAIN_BLACKLIST', '')
  config.x.email_domains_allowlist = ENV.fetch('EMAIL_DOMAIN_ALLOWLIST', nil) || ENV.fetch('EMAIL_DOMAIN_WHITELIST', '')
end

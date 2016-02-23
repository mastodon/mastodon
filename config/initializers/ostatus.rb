LOCAL_DOMAIN       = ENV['LOCAL_DOMAIN'] || 'localhost'
HUB_URL            = ENV['HUB_URL']      || 'https://pubsubhubbub.superfeedr.com'
CANONICAL_PROTOCOL = ENV['LOCAL_HTTPS'] == 'true' ? 'https://' : 'http://'

Rails.application.configure do
  config.action_mailer.default_url_options = { host: LOCAL_DOMAIN, protocol: CANONICAL_PROTOCOL }
end

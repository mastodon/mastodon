# frozen_string_literal: true

port     = ENV.fetch('PORT') { 3000 }
host     = ENV.fetch('LOCAL_DOMAIN') { "localhost:#{port}" }
web_host = ENV.fetch('WEB_DOMAIN') { host }
https    = ENV['LOCAL_HTTPS'] == 'true'

alternate_domains = ENV.fetch('ALTERNATE_DOMAINS') { '' }

Rails.application.configure do
  config.x.local_domain = host
  config.x.web_domain   = web_host
  config.x.use_https    = https
  config.x.use_s3       = ENV['S3_ENABLED'] == 'true'
  config.x.use_swift    = ENV['SWIFT_ENABLED'] == 'true'

  config.x.alternate_domains = alternate_domains.split(/\s*,\s*/)

  config.action_mailer.default_url_options = { host: web_host, protocol: https ? 'https://' : 'http://', trailing_slash: false }
  config.x.streaming_api_base_url          = 'ws://localhost:4000'
  config.x.use_ostatus_privacy             = true

  if Rails.env.production?
    config.x.streaming_api_base_url = ENV.fetch('STREAMING_API_BASE_URL') { "ws#{https ? 's' : ''}://#{web_host}" }
  end
end

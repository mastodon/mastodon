port = ENV.fetch('PORT') { 3000 }

Rails.application.configure do
  config.x.local_domain = ENV.fetch('LOCAL_DOMAIN') { "localhost:#{port}" }
  config.x.hub_url      = ENV.fetch('HUB_URL')      { 'https://pubsubhubbub.superfeedr.com' }
  config.x.use_https    = ENV['LOCAL_HTTPS'] == 'true'
  config.x.use_s3       = ENV['S3_ENABLED'] == 'true'

  config.action_mailer.default_url_options = { host: config.x.local_domain, protocol: config.x.use_https ? 'https://' : 'http://', trailing_slash: false }

  if Rails.env.production?
    config.action_cable.allowed_request_origins = ["http#{config.x.use_https ? 's' : ''}://#{config.x.local_domain}"]
  end
end

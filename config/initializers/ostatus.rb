port  = ENV.fetch('PORT') { 3000 }
host  = ENV.fetch('LOCAL_DOMAIN') { "localhost:#{port}" }
https = ENV['LOCAL_HTTPS'] == 'true'
  
Rails.application.configure do
  config.x.local_domain = host
  config.x.hub_url      = ENV.fetch('HUB_URL') { 'https://pubsubhubbub.superfeedr.com' }
  config.x.use_https    = https
  config.x.use_s3       = ENV['S3_ENABLED'] == 'true'

  config.action_mailer.default_url_options = { host: host, protocol: https ? 'https://' : 'http://', trailing_slash: false }

  if Rails.env.production?
    config.action_cable.allowed_request_origins = ["http#{https ? 's' : ''}://#{host}"]
  end
end

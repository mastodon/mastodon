# frozen_string_literal: true

port     = ENV.fetch('PORT') { 3000 }
host     = ENV.fetch('LOCAL_DOMAIN') { "localhost:#{port}" }
web_host = ENV.fetch('WEB_DOMAIN') { host }

alternate_domains = ENV.fetch('ALTERNATE_DOMAINS') { '' }.split(/\s*,\s*/)

Rails.application.configure do
  https = Rails.env.production? || ENV['LOCAL_HTTPS'] == 'true'

  config.x.local_domain = host
  config.x.web_domain   = web_host
  config.x.use_https    = https
  config.x.use_s3       = ENV['S3_ENABLED'] == 'true'
  config.x.use_swift    = ENV['SWIFT_ENABLED'] == 'true'

  config.x.alternate_domains = alternate_domains

  config.action_mailer.default_url_options = { host: web_host, protocol: https ? 'https://' : 'http://', trailing_slash: false }

  config.x.streaming_api_base_url = ENV.fetch('STREAMING_API_BASE_URL') do
    if Rails.env.production?
      "ws#{https ? 's' : ''}://#{web_host}"
    else
      "ws://#{host.split(':').first}:4000"
    end
  end

  unless Rails.env.test?
    response_app = ->(env) do
      request = ActionDispatch::Request.new(env)

      body = ApplicationController.renderer.render 'errors/blocked_host', layout: 'anonymous_error', locals: { host: request.host }, formats: [:html]

      status  = 403
      headers = {
        'Content-Type' => "text/html; charset=#{ActionDispatch::Response.default_charset}",
        'Content-Length' => body.bytesize.to_s,
      }

      [403, headers, [body]]
    end

    config.hosts << host if host.present?
    config.hosts << web_host if web_host.present?
    config.hosts.concat(alternate_domains) if alternate_domains.present?
    config.host_authorization = { response_app: response_app, exclude: ->(request) { request.path == '/health' } }
  end
end

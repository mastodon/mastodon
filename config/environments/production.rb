# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.asset_host = ENV['CDN_HOST'] if ENV['CDN_HOST'].present?

  # Specifies the header that your server uses for sending files.
  config.action_dispatch.x_sendfile_header = ENV['SENDFILE_HEADER'] if ENV['SENDFILE_HEADER'].present?
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Allow to specify public IP of reverse proxy if it's needed
  config.action_dispatch.trusted_proxies = ENV['TRUSTED_PROXY_IP'].split(/(?:\s*,\s*|\s+)/).map { |item| IPAddr.new(item) } if ENV['TRUSTED_PROXY_IP'].present?

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = {
    redirect: {
      exclude: ->(request) { request.path.start_with?('/health') || request.headers['Host'].end_with?('.onion') || request.headers['Host'].end_with?('.i2p') },
    },
  }

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout, formatter: config.log_formatter)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, REDIS_CONFIGURATION.cache

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Better log formatting
  config.lograge.enabled = true

  config.lograge.custom_payload do |controller|
    { key: controller.signature_key_id } if controller.respond_to?(:signed_request?) && controller.signed_request?
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  # This setting would typically be `true` to use the `I18n.default_locale`.
  # Some locales are missing translation entries and would have errors:
  # https://github.com/mastodon/mastodon/pull/24727
  config.i18n.fallbacks = [:en]

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.perform_caching = false

  # E-mails
  outgoing_email_address = config.x.email.from_address
  outgoing_email_domain  = Mail::Address.new(outgoing_email_address).domain

  config.action_mailer.default_options = {
    from: outgoing_email_address,
    message_id: -> { "<#{Mail.random_tag}@#{outgoing_email_domain}>" },
  }

  config.action_mailer.default_options[:reply_to]    = config.x.email.reply_to if config.x.email.reply_to.present?
  config.action_mailer.default_options[:return_path] = config.x.email.return_path if config.x.email.return_path.present?

  config.action_mailer.smtp_settings = Mastodon::EmailConfigurationHelper.convert_smtp_settings(config.x.email.smtp_settings)

  config.action_mailer.delivery_method = config.x.email.delivery_method.to_sym

  config.action_dispatch.default_headers = {
    'Server' => 'Mastodon',
    'X-Frame-Options' => 'DENY',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '0',
    'Referrer-Policy' => 'same-origin',
  }

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

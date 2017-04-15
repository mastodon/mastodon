Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_controller.asset_host      = ENV['CDN_HOST'] if ENV.key?('CDN_HOST')

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(mangle: false)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Allow to specify public IP of reverse proxy if it's needed
  config.action_dispatch.trusted_proxies = [IPAddr.new(ENV['TRUSTED_PROXY_IP'])] unless ENV['TRUSTED_PROXY_IP'].blank?

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false

  # By default, use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Parse and split the REDIS_URL if passed (used with hosting platforms such as Heroku).
  # Set ENV variables because they are used elsewhere.
  if ENV['REDIS_URL']
    redis_url = URI.parse(ENV['REDIS_URL'])
    ENV['REDIS_HOST'] = redis_url.host
    ENV['REDIS_PORT'] = redis_url.port.to_s
    ENV['REDIS_PASSWORD'] = redis_url.password
    db_num = redis_url.path[1..-1]
    ENV['REDIS_DB'] = db_num if db_num.present?
  end

  # Use a different cache store in production.
  config.cache_store = :redis_store, {
    host: ENV.fetch('REDIS_HOST') { 'localhost' },
    port: ENV.fetch('REDIS_PORT') { 6379 },
    password: ENV.fetch('REDIS_PASSWORD') { false },
    db: ENV.fetch('REDIS_DB') { 0 },
    namespace: 'cache',
    expires_in: 10.minutes,
  }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Better log formatting
  config.lograge.enabled = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.perform_caching = false

  # E-mails
  config.action_mailer.smtp_settings = {
    :port                 => ENV['SMTP_PORT'],
    :address              => ENV['SMTP_SERVER'],
    :user_name            => ENV['SMTP_LOGIN'],
    :password             => ENV['SMTP_PASSWORD'],
    :domain               => ENV['SMTP_DOMAIN'] || ENV['LOCAL_DOMAIN'],
    :authentication       => ENV['SMTP_AUTH_METHOD'] || :plain,
    :openssl_verify_mode  => ENV['SMTP_OPENSSL_VERIFY_MODE'],
    :enable_starttls_auto => ENV['SMTP_ENABLE_STARTTLS_AUTO'] || true,
  }

  config.action_mailer.delivery_method = ENV.fetch('SMTP_DELIVERY_METHOD', 'smtp').to_sym


  config.react.variant = :production

  config.to_prepare do
    StatsD.backend = StatsD::Instrument::Backends::NullBackend.new if ENV['STATSD_ADDR'].blank?
  end

  config.action_dispatch.default_headers = {
    'Server'                 => 'Mastodon',
    'X-Frame-Options'        => 'DENY',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection'       => '1; mode=block',
  }
end

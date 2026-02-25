# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 3.2.0', '< 3.5.0'

gem 'propshaft'
gem 'puma', '~> 7.0'
gem 'rails', '~> 8.0'
gem 'thor', '~> 1.2'

gem 'dotenv'
gem 'haml-rails', '~>3.0'
gem 'pg', '~> 1.5'
gem 'pghero'

gem 'aws-sdk-core', require: false
gem 'aws-sdk-s3', '~> 1.123', require: false
gem 'blurhash', '~> 0.1'
gem 'fog-core', '<= 2.6.0'
gem 'fog-openstack', '~> 1.0', require: false
gem 'jd-paperclip-azure', '~> 3.0', require: false
gem 'kt-paperclip', '~> 7.2'
gem 'ruby-vips', '~> 2.2', require: false

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.8'
gem 'bootsnap', require: false
gem 'browser'
gem 'charlock_holmes', '~> 0.7.7'
gem 'chewy', '~> 7.3'
gem 'devise'
gem 'devise-two-factor'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.18'

gem 'omniauth', '~> 2.0'
gem 'omniauth-cas', '~> 3.0.0.beta.1'
gem 'omniauth_openid_connect', '~> 0.8.0'
gem 'omniauth-rails_csrf_protection', '~> 2.0'
gem 'omniauth-saml', '~> 2.0'

gem 'color_diff', '~> 0.1'
gem 'csv', '~> 3.2'
gem 'discard', '~> 1.2'
gem 'doorkeeper', '~> 5.6'
gem 'faraday-httpclient'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'hiredis', '~> 0.6'
gem 'hiredis-client'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 5.3.0'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 1.8.0', require: false
gem 'i18n'
gem 'idn-ruby', require: 'idn'
gem 'inline_svg'
gem 'irb', '~> 1.8'
gem 'kaminari', '~> 1.2'
gem 'link_header', '~> 0.0'
gem 'linzer', '~> 0.7.7'
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'mime-types', '~> 3.7.0', require: 'mime/types/columnar'
gem 'mutex_m'
gem 'nokogiri', '~> 1.15'
gem 'oj', '~> 3.14'
gem 'ox', '~> 2.14'
gem 'parslet'
gem 'premailer-rails'
gem 'public_suffix', '~> 7.0'
gem 'pundit', '~> 2.3'
gem 'rack-attack', '~> 6.6'
gem 'rack-cors', require: 'rack/cors'
gem 'rails-i18n', '~> 8.0'
gem 'redcarpet', '~> 3.6'
gem 'redis', '~> 4.5', require: ['redis', 'redis/connection/hiredis']
gem 'rqrcode', '~> 3.0'
gem 'ruby-progressbar', '~> 1.13'
gem 'sanitize', '~> 7.0'
gem 'scenic', '~> 1.7'
gem 'sidekiq', '< 9'
gem 'sidekiq-bulk', '~> 0.2.0'
gem 'sidekiq-scheduler', '~> 6.0'
gem 'sidekiq-unique-jobs', '> 8'
gem 'simple_form', '~> 5.2'
gem 'simple-navigation', '~> 4.4'
gem 'stoplight'
gem 'strong_migrations'
gem 'tty-prompt', '~> 0.23', require: false
gem 'twitter-text', '~> 3.1.0'
gem 'tzinfo-data', '~> 1.2023'
gem 'webauthn', '~> 3.0'
gem 'webpush', github: 'mastodon/webpush', ref: '9631ac63045cfabddacc69fc06e919b4c13eb913'

gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.2'
gem 'rdf-normalize', '~> 0.5'

gem 'prometheus_exporter', '~> 2.2', require: false

gem 'opentelemetry-api', '~> 1.7.0'

group :opentelemetry do
  gem 'opentelemetry-exporter-otlp', '~> 0.31.0', require: false
  gem 'opentelemetry-instrumentation-active_job', '~> 0.10.0', require: false
  gem 'opentelemetry-instrumentation-active_model_serializers', '~> 0.24.0', require: false
  gem 'opentelemetry-instrumentation-concurrent_ruby', '~> 0.24.0', require: false
  gem 'opentelemetry-instrumentation-excon', '~> 0.27.0', require: false
  gem 'opentelemetry-instrumentation-faraday', '~> 0.31.0', require: false
  gem 'opentelemetry-instrumentation-http', '~> 0.28.0', require: false
  gem 'opentelemetry-instrumentation-http_client', '~> 0.27.0', require: false
  gem 'opentelemetry-instrumentation-net_http', '~> 0.27.0', require: false
  gem 'opentelemetry-instrumentation-pg', '~> 0.35.0', require: false
  gem 'opentelemetry-instrumentation-rack', '~> 0.29.0', require: false
  gem 'opentelemetry-instrumentation-rails', '~> 0.39.0', require: false
  gem 'opentelemetry-instrumentation-redis', '~> 0.28.0', require: false
  gem 'opentelemetry-instrumentation-sidekiq', '~> 0.28.0', require: false
  gem 'opentelemetry-sdk', '~> 1.4', require: false
end

group :test do
  # Enable usage of all available CPUs/cores during spec runs
  gem 'flatware-rspec'

  # Adds RSpec Error/Warning annotations to GitHub PRs on the Files tab
  gem 'rspec-github', '~> 3.0', require: false

  # RSpec helpers for email specs
  gem 'email_spec'

  # Extra RSpec extension methods and helpers for sidekiq
  gem 'rspec-sidekiq', '~> 5.0'

  # Browser integration testing
  gem 'capybara', '~> 3.39'
  gem 'capybara-playwright-driver'
  gem 'playwright-ruby-client', '1.57.1', require: false # Pinning the exact version as it needs to be kept in sync with the installed npm package

  # Used to reset the database between system tests
  gem 'database_cleaner-active_record'

  # Used to mock environment variables
  gem 'climate_control'

  # Validate schemas in specs
  gem 'json-schema', '~> 6.0'

  # Test harness fo rack components
  gem 'rack-test', '~> 2.1'

  gem 'shoulda-matchers'

  # Coverage formatter for RSpec
  gem 'simplecov', '~> 0.22', require: false
  gem 'simplecov-lcov', '~> 0.8', require: false

  # Stub web requests for specs
  gem 'webmock', '~> 3.18'

  # Websocket driver for testing integration between rails/sidekiq and streaming
  gem 'websocket-driver', '~> 0.8', require: false
end

group :development do
  # Code linting CLI and plugins
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-i18n', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  # Annotates modules with schema
  gem 'annotaterb', '~> 4.13', require: false

  # Enhanced error message pages for development
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'

  # Preview mail in the browser
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 3.0'

  # Security analysis CLI tools
  gem 'brakeman', '~> 8.0', require: false
  gem 'bundler-audit', '~> 0.9', require: false

  # Linter CLI for HAML files
  gem 'haml_lint', require: false

  # Validate missing i18n keys
  gem 'i18n-tasks', '~> 1.0', require: false
end

group :development, :test do
  # Interactive Debugging tools
  gem 'debug', '~> 1.8', require: false

  # Generate fake data values
  gem 'faker', '~> 3.2'

  # Generate factory objects
  gem 'fabrication'

  # Profiling tools
  gem 'memory_profiler', require: false
  gem 'ruby-prof', require: false
  gem 'stackprof', require: false
  gem 'test-prof', require: false

  # RSpec runner for rails
  gem 'rspec-rails', '~> 8.0'
end

group :production do
  gem 'lograge', '~> 0.12'
end

gem 'cocoon', '~> 1.2'
gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false
gem 'xorcist', '~> 1.1'

gem 'net-http', '~> 0.6.0'
gem 'rubyzip', '~> 3.0'

gem 'hcaptcha', '~> 7.1'

gem 'mail', '~> 2.8'

gem 'vite_rails', '~> 3.0.19'

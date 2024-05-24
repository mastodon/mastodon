# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 3.1.0'

gem 'propshaft'
gem 'puma', '~> 6.3'
gem 'rack', '~> 2.2.7'
gem 'rails', '~> 7.1.1'
gem 'thor', '~> 1.2'

# For why irb is in the Gemfile, see: https://ruby.social/@st0012/111444685161478182
gem 'irb', '~> 1.8'

gem 'dotenv'
gem 'haml-rails', '~>2.0'
gem 'pg', '~> 1.5'
gem 'pghero'

gem 'aws-sdk-s3', '~> 1.123', require: false
gem 'blurhash', '~> 0.1'
gem 'fog-core', '<= 2.4.0'
gem 'fog-openstack', '~> 1.0', require: false
gem 'kt-paperclip', '~> 7.2'
gem 'md-paperclip-azure', '~> 2.2', require: false

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.8'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'browser'
gem 'charlock_holmes', '~> 0.7.7'
gem 'chewy', '~> 7.3'
gem 'devise', '~> 4.9'
gem 'devise-two-factor'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.18'

gem 'omniauth', '~> 2.0'
gem 'omniauth-cas', '~> 3.0.0.beta.1'
gem 'omniauth_openid_connect', '~> 0.6.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'omniauth-saml', '~> 2.0'

gem 'color_diff', '~> 0.1'
gem 'csv', '~> 3.2'
gem 'discard', '~> 1.2'
gem 'doorkeeper', '~> 5.6'
gem 'ed25519', '~> 1.3'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'hiredis', '~> 0.6'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 5.2.0'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 1.6.2'
gem 'i18n'
gem 'idn-ruby', require: 'idn'
gem 'inline_svg'
gem 'kaminari', '~> 1.2'
gem 'link_header', '~> 0.0'
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'mime-types', '~> 3.5.0', require: 'mime/types/columnar'
gem 'nokogiri', '~> 1.15'
gem 'nsa'
gem 'oj', '~> 3.14'
gem 'ox', '~> 2.14'
gem 'parslet'
gem 'premailer-rails'
gem 'public_suffix', '~> 5.0'
gem 'pundit', '~> 2.3'
gem 'rack-attack', '~> 6.6'
gem 'rack-cors', '~> 2.0', require: 'rack/cors'
gem 'rails-i18n', '~> 7.0'
gem 'redcarpet', '~> 3.6'
gem 'redis', '~> 4.5', require: ['redis', 'redis/connection/hiredis']
gem 'redis-namespace', '~> 1.10'
gem 'rqrcode', '~> 2.2'
gem 'ruby-progressbar', '~> 1.13'
gem 'sanitize', '~> 6.0'
gem 'scenic', '~> 1.7'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-bulk', '~> 0.2.0'
gem 'sidekiq-scheduler', '~> 5.0'
gem 'sidekiq-unique-jobs', '~> 7.1'
gem 'simple_form', '~> 5.2'
gem 'simple-navigation', '~> 4.4'
gem 'stoplight', '~> 4.1'
gem 'strong_migrations', '1.8.0'
gem 'tty-prompt', '~> 0.23', require: false
gem 'twitter-text', '~> 3.1.0'
gem 'tzinfo-data', '~> 1.2023'
gem 'webauthn', '~> 3.0'
gem 'webpacker', '~> 5.4'
gem 'webpush', github: 'ClearlyClaire/webpush', ref: 'f14a4d52e201128b1b00245d11b6de80d6cfdcd9'

gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.2'
gem 'rdf-normalize', '~> 0.5'

gem 'private_address_check', '~> 0.5'

gem 'opentelemetry-api', '~> 1.2.5'

group :opentelemetry do
  gem 'opentelemetry-exporter-otlp', '~> 0.26.3', require: false
  gem 'opentelemetry-instrumentation-active_job', '~> 0.7.1', require: false
  gem 'opentelemetry-instrumentation-active_model_serializers', '~> 0.20.1', require: false
  gem 'opentelemetry-instrumentation-concurrent_ruby', '~> 0.21.2', require: false
  gem 'opentelemetry-instrumentation-excon', '~> 0.22.0', require: false
  gem 'opentelemetry-instrumentation-faraday', '~> 0.24.1', require: false
  gem 'opentelemetry-instrumentation-http', '~> 0.23.2', require: false
  gem 'opentelemetry-instrumentation-http_client', '~> 0.22.3', require: false
  gem 'opentelemetry-instrumentation-net_http', '~> 0.22.4', require: false
  gem 'opentelemetry-instrumentation-pg', '~> 0.27.1', require: false
  gem 'opentelemetry-instrumentation-rack', '~> 0.24.1', require: false
  gem 'opentelemetry-instrumentation-rails', '~> 0.30.0', require: false
  gem 'opentelemetry-instrumentation-redis', '~> 0.25.3', require: false
  gem 'opentelemetry-instrumentation-sidekiq', '~> 0.25.2', require: false
  gem 'opentelemetry-sdk', '~> 1.4', require: false
end

group :test do
  # Adds RSpec Error/Warning annotations to GitHub PRs on the Files tab
  gem 'rspec-github', '~> 2.4', require: false

  # RSpec progress bar formatter
  gem 'fuubar', '~> 2.5'

  # RSpec helpers for email specs
  gem 'email_spec'

  # Extra RSpec extension methods and helpers for sidekiq
  gem 'rspec-sidekiq', '~> 5.0'

  # Browser integration testing
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver'

  # Used to reset the database between system tests
  gem 'database_cleaner-active_record'

  # Used to mock environment variables
  gem 'climate_control'

  # Add back helpers functions removed in Rails 5.1
  gem 'rails-controller-testing', '~> 1.0'

  # Validate schemas in specs
  gem 'json-schema', '~> 4.0'

  # Test harness fo rack components
  gem 'rack-test', '~> 2.1'

  # Coverage formatter for RSpec test if DISABLE_SIMPLECOV is false
  gem 'simplecov', '~> 0.22', require: false
  gem 'simplecov-lcov', '~> 0.8', require: false

  # Stub web requests for specs
  gem 'webmock', '~> 3.18'
end

group :development do
  # Code linting CLI and plugins
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Annotates modules with schema
  gem 'annotate', '~> 3.2'

  # Enhanced error message pages for development
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'

  # Preview mail in the browser
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 3.0'

  # Security analysis CLI tools
  gem 'brakeman', '~> 6.0', require: false
  gem 'bundler-audit', '~> 0.9', require: false

  # Linter CLI for HAML files
  gem 'haml_lint', require: false

  # Validate missing i18n keys
  gem 'i18n-tasks', '~> 1.0', require: false
end

group :development, :test do
  # Interactive Debugging tools
  gem 'debug', '~> 1.8'

  # Generate fake data values
  gem 'faker', '~> 3.2'

  # Generate factory objects
  gem 'fabrication', '~> 2.30'

  # Profiling tools
  gem 'memory_profiler', require: false
  gem 'ruby-prof', require: false
  gem 'stackprof', require: false
  gem 'test-prof'

  # RSpec runner for rails
  gem 'rspec-rails', '~> 6.0'
end

group :production do
  gem 'lograge', '~> 0.12'
end

gem 'cocoon', '~> 1.2'
gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false
gem 'xorcist', '~> 1.1'

gem 'net-http', '~> 0.4.0'
gem 'rubyzip', '~> 2.3'

gem 'hcaptcha', '~> 7.1'

gem 'mail', '~> 2.8'

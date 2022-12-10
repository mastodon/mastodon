# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.7.0', '< 3.2.0'

# Detect need libraries for compiling Ruby native extensions
gem 'pkg-config', '~> 1.5'

# Environment variables
gem 'dotenv-rails', '~> 2.8'

# Webserver
gem 'puma', '~> 5.6'
gem 'rack', '~> 2.2.4'
gem 'rack-attack', '~> 6.6'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'

# Rails
gem 'rails', '~> 6.1.7'
gem 'rails-i18n', '~> 6.0'
gem 'bootsnap', '~> 1.15.0', require: false

# Database
gem 'pg', '~> 1.4'
gem 'discard', '~> 1.2'
gem 'makara', '~> 0.5'
gem 'pghero', '~> 2.8'
gem 'rails-settings-cached', '~> 0.6', git: 'https://github.com/zunda/rails-settings-cached.git', branch: 'v0.6.6-aliases-true'
gem 'scenic', '~> 1.6' # Versioned database views for Rails
gem 'strong_migrations', '~> 0.7'

# Redis
gem 'redis', '~> 4.5', require: ['redis', 'redis/connection/hiredis']
gem 'redis-namespace', '~> 1.9'
gem 'hiredis', '~> 0.6'

# Distributed lock
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'

# Assets
gem 'sprockets', '~> 3.7.2'
gem 'sprockets-rails', '~> 3.4', require: 'sprockets/railtie'
gem 'webpacker', '~> 5.4'

# Authorization
gem 'pundit', '~> 2.2'

# Authenication
group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end
gem 'devise-two-factor', '~> 4.0'
gem 'devise', '~> 4.8'
gem 'doorkeeper', '~> 5.6'
gem 'gitlab-omniauth-openid-connect', '~>0.10.0', require: 'omniauth_openid_connect'
gem 'net-ldap', '~> 0.17'
gem 'omniauth-cas', '~> 2.0'
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'omniauth-saml', '~> 1.10'
gem 'omniauth', '~> 1.9'

# WebAuthn Relying Party
gem 'webauthn', '~> 2.5'

# Security
gem 'ed25519', '~> 1.3'
gem 'rqrcode', '~> 2.1' # MFA QR code
gem 'sanitize', '~> 6.0' # HTML and CSS sanitizer

# JSON and XML
gem 'active_model_serializers', '~> 0.10'
gem 'nokogiri', '~> 1.13'
gem 'oj', '~> 3.13'
gem 'ox', '~> 2.14'
gem 'rexml', '~> 3.2'

# File uploads
gem 'aws-sdk-s3', '~> 1.117.2', require: false
gem 'fog-core', '<= 2.1.0'
gem 'fog-openstack', '~> 0.3', require: false
gem 'kt-paperclip', '~> 7.1'
gem 'blurhash', '~> 0.1'
gem 'fastimage'
gem 'color_diff', '~> 0.1'
gem 'mime-types', '~> 3.4.1', require: 'mime/types/columnar'

# HTTP client & extensions
gem 'addressable', '~> 2.8'
gem 'htmlentities', '~> 4.3'
gem 'http_accept_language', '~> 2.1'
gem 'http', '~> 5.1'
gem 'httplog', '~> 1.6.2'
gem 'idn-ruby', require: 'idn'
gem 'link_header', '~> 0.0'

# Linked Data and Semantic Web
gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.2'
gem 'rdf-normalize', '~> 0.5'

# Parser
gem 'parslet'
gem 'twitter-text', '~> 3.1.0' # Parsing of Tweet text

# View templates
gem 'hamlit-rails', '~> 0.2'

# Navigation helper
gem 'simple-navigation', '~> 4.4'

# Form builder
gem 'simple_form', '~> 5.1'
gem 'cocoon', '~> 1.2'

# Pagination
gem 'kaminari', '~> 1.2'

# Markdown
gem 'redcarpet', '~> 3.5'

# Emails
gem 'net-smtp', require: false
gem 'premailer-rails'

# Web Push protocol
gem 'webpush', github: 'ClearlyClaire/webpush', ref: 'f14a4d52e201128b1b00245d11b6de80d6cfdcd9'

# Background job processing
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-scheduler', '~> 4.0'
gem 'sidekiq-unique-jobs', '~> 7.1'
gem 'sidekiq-bulk', '~> 0.2.0'

# Elasticsearch
gem 'chewy', '~> 7.2'

# Command line interface
gem 'thor', '~> 1.2'
gem 'tty-prompt', '~> 0.23', require: false
gem 'ruby-progressbar', '~> 1.11'

# Misc
gem 'browser' # Browser detection
gem 'charlock_holmes', '~> 0.7.7' # Character encoding detection
gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false # Generic connection pooling
gem 'fast_blank', '~> 1.0' # Faster String#blank?
gem 'posix-spawn' # Should be removed https://github.com/rtomayko/posix-spawn/issues/90
gem 'public_suffix', '~> 5.0' # Domain name parsing
gem 'stoplight', '~> 3.0.1' # Circuit breaker pattern
gem 'tzinfo-data', '~> 1.2022'
gem 'xorcist', '~> 1.1' # String XOR

# Statsd
gem 'nsa', '~> 0.2'

group :production do
  gem 'lograge', '~> 0.12'
end

group :production, :test do
  gem 'private_address_check', '~> 0.5'
end

group :test do
  gem 'capybara', '~> 3.38'
  gem 'climate_control', '~> 0.2'
  gem 'faker', '~> 3.0'
  gem 'microformats', '~> 4.4'
  gem 'rack-test', '~> 2.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec_junit_formatter', '~> 0.6'
  gem 'rspec-sidekiq', '~> 3.1'
  gem 'simplecov', '~> 0.21', require: false
  gem 'webmock', '~> 3.18'
end

group :development do
  # Documentation
  gem 'annotate', '~> 3.2'

  # Displaying errors
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'

  # Security
  gem 'brakeman', '~> 5.4', require: false
  gem 'bundler-audit', '~> 0.9', require: false

  # Performance
  gem 'active_record_query_trace', '~> 1.8'
  gem 'bullet', '~> 7.0'
  gem 'memory_profiler'
  gem 'stackprof'

  # Style guide
  gem 'rubocop-rails', '~> 2.15', require: false
  gem 'rubocop', '~> 1.30', require: false

  # Previewing emails locally
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 2.0'

  # Manual deployment
  gem 'capistrano', '~> 3.17'
  gem 'capistrano-rails', '~> 1.6'
  gem 'capistrano-rbenv', '~> 2.2'
  gem 'capistrano-yarn', '~> 2.0'
end

group :development, :test do
  gem 'fabrication', '~> 2.30'
  gem 'fuubar', '~> 2.5'
  gem 'i18n-tasks', '~> 1.0', require: false
  gem 'pry-byebug', '~> 3.10', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails', '~> 0.3', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 5.1'
end
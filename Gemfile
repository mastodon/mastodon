# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.7.0', '< 3.3.0'

gem 'pkg-config', '~> 1.5'
gem 'rexml', '~> 3.2'

gem 'puma', '~> 6.1'
gem 'rails', '~> 6.1.7'
gem 'sprockets', '~> 3.7.2'
gem 'thor', '~> 1.2'
gem 'rack', '~> 2.2.6'

gem 'haml-rails', '~>2.0'
gem 'pg', '~> 1.4'
gem 'makara', '~> 0.5'
gem 'pghero'
gem 'dotenv-rails', '~> 2.8'

gem 'aws-sdk-s3', '~> 1.119', require: false
gem 'fog-core', '<= 2.4.0'
gem 'fog-openstack', '~> 0.3', require: false
gem 'kt-paperclip', '~> 7.1', github: 'kreeti/kt-paperclip', ref: '11abf222dc31bff71160a1d138b445214f434b2b'
gem 'blurhash', '~> 0.1'

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.8'
gem 'bootsnap', '~> 1.16.0', require: false
gem 'browser'
gem 'charlock_holmes', '~> 0.7.7'
gem 'chewy', '~> 7.2'
gem 'devise', '~> 4.9'
gem 'devise-two-factor', '~> 4.0'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.17'
gem 'omniauth-cas', '~> 2.0'
gem 'omniauth-saml', '~> 1.10'
gem 'omniauth_openid_connect', '~> 0.6.0'
gem 'omniauth', '~> 1.9'
gem 'omniauth-rails_csrf_protection', '~> 0.1'

gem 'color_diff', '~> 0.1'
gem 'discard', '~> 1.2'
gem 'doorkeeper', '~> 5.6'
gem 'ed25519', '~> 1.3'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.10'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 5.1'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 1.6.2'
gem 'idn-ruby', require: 'idn'
gem 'kaminari', '~> 1.2'
gem 'link_header', '~> 0.0'
gem 'mime-types', '~> 3.4.1', require: 'mime/types/columnar'
gem 'nokogiri', '~> 1.14'
gem 'nsa', '~> 0.2'
gem 'oj', '~> 3.14'
gem 'ox', '~> 2.14'
gem 'parslet'
gem 'posix-spawn'
gem 'public_suffix', '~> 5.0'
gem 'pundit', '~> 2.3'
gem 'premailer-rails'
gem 'rack-attack', '~> 6.6'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'
gem 'rails-i18n', '~> 6.0'
gem 'rails-settings-cached', '~> 0.6', git: 'https://github.com/mastodon/rails-settings-cached.git', branch: 'v0.6.6-aliases-true'
gem 'redcarpet', '~> 3.6'
gem 'redis', '~> 4.5', require: ['redis', 'redis/connection/hiredis']
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'rqrcode', '~> 2.1'
gem 'ruby-progressbar', '~> 1.11'
gem 'sanitize', '~> 6.0'
gem 'scenic', '~> 1.7'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-scheduler', '~> 5.0'
gem 'sidekiq-unique-jobs', '~> 7.1'
gem 'sidekiq-bulk', '~> 0.2.0'
gem 'simple-navigation', '~> 4.4'
gem 'simple_form', '~> 5.2'
gem 'sprockets-rails', '~> 3.4', require: 'sprockets/railtie'
gem 'stoplight', '~> 3.0.1'
gem 'strong_migrations', '~> 0.7'
gem 'tty-prompt', '~> 0.23', require: false
gem 'twitter-text', '~> 3.1.0'
gem 'tzinfo-data', '~> 1.2022'
gem 'webpacker', '~> 5.4'
gem 'webpush', github: 'ClearlyClaire/webpush', ref: 'f14a4d52e201128b1b00245d11b6de80d6cfdcd9'
gem 'webauthn', '~> 3.0'

gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.2'
gem 'rdf-normalize', '~> 0.5'

group :development, :test do
  gem 'fabrication', '~> 2.30'
  gem 'fuubar', '~> 2.5'
  gem 'i18n-tasks', '~> 1.0', require: false
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop', require: false
end

group :production, :test do
  gem 'private_address_check', '~> 0.5'
end

group :test do
  gem 'capybara', '~> 3.38'
  gem 'faker', '~> 3.1'
  gem 'json-schema', '~> 3.0'
  gem 'rack-test', '~> 2.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec_junit_formatter', '~> 0.6'
  gem 'rspec-sidekiq', '~> 3.1'
  gem 'simplecov', '~> 0.22', require: false
  gem 'webmock', '~> 3.18'
end

group :development do
  gem 'active_record_query_trace', '~> 1.8'
  gem 'annotate', '~> 3.2'
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'bullet', '~> 7.0'
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 2.0'
  gem 'memory_profiler'
  gem 'brakeman', '~> 5.4', require: false
  gem 'bundler-audit', '~> 0.9', require: false
  gem 'haml_lint', require: false

  gem 'capistrano', '~> 3.17'
  gem 'capistrano-rails', '~> 1.6'
  gem 'capistrano-rbenv', '~> 2.2'
  gem 'capistrano-yarn', '~> 2.0'

  gem 'stackprof'
end

group :production do
  gem 'lograge', '~> 0.12'
end

gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false
gem 'xorcist', '~> 1.1'
gem 'cocoon', '~> 1.2'

gem 'net-http', '~> 0.3.2'

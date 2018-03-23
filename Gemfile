# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.3.0', '< 2.6.0'

gem 'pkg-config', '~> 1.2'

gem 'puma', '~> 3.10'
gem 'rails', '~> 5.1.4'

gem 'hamlit-rails', '~> 0.2'
gem 'pg', '~> 0.20'
gem 'pghero', '~> 1.7'
gem 'dotenv-rails', '~> 2.2'

gem 'aws-sdk', '~> 2.10', require: false
gem 'fog-core', '~> 1.45'
gem 'fog-local', '~> 0.4', require: false
gem 'fog-openstack', '~> 0.1', require: false
gem 'paperclip', '~> 5.1'
gem 'paperclip-av-transcoder', '~> 0.6'
gem 'streamio-ffmpeg', '~> 3.0'

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.5'
gem 'bootsnap'
gem 'browser'
gem 'charlock_holmes', '~> 0.7.5'
gem 'iso-639'
gem 'chewy', '~> 5.0'
gem 'cld3', '~> 3.2.0'
gem 'devise', '~> 4.4'
gem 'devise-two-factor', '~> 3.0'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.0'
end
gem 'net-ldap', '~> 0.10'
gem 'omniauth-cas', '~> 1.1'
gem 'omniauth-saml', '~> 1.10'
gem 'omniauth', '~> 1.2'

gem 'doorkeeper', '~> 4.2'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'goldfinger', '~> 2.1'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.5'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 3.0'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 0.99'
gem 'idn-ruby', require: 'idn'
gem 'kaminari', '~> 1.1'
gem 'link_header', '~> 0.0'
gem 'mime-types', '~> 3.1'
gem 'nokogiri', '~> 1.8'
gem 'nsa', '~> 0.2'
gem 'oj', '~> 3.3'
gem 'ostatus2', '~> 2.0'
gem 'ox', '~> 2.8'
gem 'pundit', '~> 1.1'
gem 'premailer-rails'
gem 'rack-attack', '~> 5.0'
gem 'rack-cors', '~> 0.4', require: 'rack/cors'
gem 'rack-timeout', '~> 0.4'
gem 'rails-i18n', '~> 5.0'
gem 'rails-settings-cached', '~> 0.6'
gem 'redis', '~> 3.3', require: ['redis', 'redis/connection/hiredis']
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'rqrcode', '~> 0.10'
gem 'ruby-oembed', '~> 0.12', require: 'oembed'
gem 'ruby-progressbar', '~> 1.4'
gem 'sanitize', '~> 4.6.4'
gem 'sidekiq', '~> 5.0'
gem 'sidekiq-scheduler', '~> 2.1'
gem 'sidekiq-unique-jobs', '~> 5.0'
gem 'sidekiq-bulk', '~>0.1.1'
gem 'simple-navigation', '~> 4.0'
gem 'simple_form', '~> 3.4'
gem 'sprockets-rails', '~> 3.2', require: 'sprockets/railtie'
gem 'strong_migrations'
gem 'tty-command'
gem 'tty-prompt'
gem 'twitter-text', '~> 1.14'
gem 'tzinfo-data', '~> 1.2017'
gem 'webpacker', '~> 3.0'
gem 'webpush'

gem 'json-ld-preloaded', '~> 2.2.1'
gem 'rdf-normalize', '~> 0.3.1'

group :development, :test do
  gem 'fabrication', '~> 2.18'
  gem 'fuubar', '~> 2.2'
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 3.7'
end

group :production, :test do
  gem 'private_address_check', '~> 0.4.1'
end

group :test do
  gem 'capybara', '~> 2.15'
  gem 'climate_control', '~> 0.2'
  gem 'faker', '~> 1.7'
  gem 'microformats', '~> 4.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-sidekiq', '~> 3.0'
  gem 'simplecov', '~> 0.14', require: false
  gem 'webmock', '~> 3.0'
  gem 'parallel_tests', '~> 2.17'
end

group :development do
  gem 'active_record_query_trace', '~> 1.5'
  gem 'annotate', '~> 2.7'
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller', '~> 0.7'
  gem 'bullet', '~> 5.5'
  gem 'letter_opener', '~> 1.4'
  gem 'letter_opener_web', '~> 1.3'
  gem 'memory_profiler'
  gem 'rubocop', require: false
  gem 'brakeman', '~> 4.0', require: false
  gem 'bundler-audit', '~> 0.6', require: false
  gem 'scss_lint', '~> 0.55', require: false

  gem 'capistrano', '~> 3.10'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-yarn', '~> 2.0'
end

group :production do
  gem 'lograge', '~> 0.7'
  gem 'redis-rails', '~> 5.0'
end

# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.4.0', '< 2.7.0'

gem 'pkg-config', '~> 1.3'

gem 'puma', '~> 3.12'
gem 'rails', '~> 5.2.3'
gem 'thor', '~> 0.20'

gem 'hamlit-rails', '~> 0.2'
gem 'pg', '~> 1.1'
gem 'makara', '~> 0.4'
gem 'pghero', '~> 2.2'
gem 'dotenv-rails', '~> 2.7'

gem 'aws-sdk-s3', '~> 1.36', require: false
gem 'fog-core', '<= 2.1.0'
gem 'fog-openstack', '~> 0.3', require: false
gem 'paperclip', '~> 6.0'
gem 'paperclip-av-transcoder', '~> 0.6'
gem 'streamio-ffmpeg', '~> 3.0'

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.6'
gem 'bootsnap', '~> 1.4', require: false
gem 'browser'
gem 'charlock_holmes', '~> 0.7.6'
gem 'iso-639'
gem 'chewy', '~> 5.0'
gem 'cld3', '~> 3.2.3'
gem 'devise', '~> 4.6'
gem 'devise-two-factor', '~> 3.0'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.10'
gem 'omniauth-cas', '~> 1.1'
gem 'omniauth-saml', '~> 1.10'
gem 'omniauth', '~> 1.9'

gem 'doorkeeper', '~> 5.0'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'goldfinger', '~> 2.1'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.5'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 3.3'
gem 'http_accept_language', '~> 2.1'
gem 'http_parser.rb', '~> 0.6', git: 'https://github.com/tmm1/http_parser.rb', ref: '54b17ba8c7d8d20a16dfc65d1775241833219cf2'
gem 'httplog', '~> 1.2'
gem 'idn-ruby', require: 'idn'
gem 'kaminari', '~> 1.1'
gem 'link_header', '~> 0.0'
gem 'mime-types', '~> 3.2', require: 'mime/types/columnar'
gem 'nokogiri', '~> 1.10'
gem 'nsa', '~> 0.2'
gem 'oj', '~> 3.7'
gem 'ostatus2', '~> 2.0'
gem 'ox', '~> 2.10'
gem 'posix-spawn', git: 'https://github.com/rtomayko/posix-spawn', ref: '58465d2e213991f8afb13b984854a49fcdcc980c'
gem 'pundit', '~> 2.0'
gem 'premailer-rails'
gem 'rack-attack', '~> 5.4'
gem 'rack-cors', '~> 1.0', require: 'rack/cors'
gem 'rails-i18n', '~> 5.1'
gem 'rails-settings-cached', '~> 0.6'
gem 'redis', '~> 4.1', require: ['redis', 'redis/connection/hiredis']
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'rqrcode', '~> 0.10'
gem 'sanitize', '~> 5.0'
gem 'sidekiq', '~> 5.2'
gem 'sidekiq-scheduler', '~> 3.0'
gem 'sidekiq-unique-jobs', '~> 6.0'
gem 'sidekiq-bulk', '~>0.2.0'
gem 'simple-navigation', '~> 4.0'
gem 'simple_form', '~> 4.1'
gem 'sprockets-rails', '~> 3.2', require: 'sprockets/railtie'
gem 'stoplight', '~> 2.1.3'
gem 'strong_migrations', '~> 0.3'
gem 'tty-command', '~> 0.8', require: false
gem 'tty-prompt', '~> 0.18', require: false
gem 'twitter-text', '~> 1.14'
gem 'tzinfo-data', '~> 1.2019'
gem 'webpacker', '~> 4.0'
gem 'webpush'

gem 'json-ld', '~> 3.0'
gem 'json-ld-preloaded', '~> 3.0'
gem 'rdf-normalize', '~> 0.3'

group :development, :test do
  gem 'fabrication', '~> 2.20'
  gem 'fuubar', '~> 2.3'
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'pry-byebug', '~> 3.7'
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 3.8'
end

group :production, :test do
  gem 'private_address_check', '~> 0.5'
end

group :test do
  gem 'capybara', '~> 3.16'
  gem 'climate_control', '~> 0.2'
  gem 'faker', '~> 1.9'
  gem 'microformats', '~> 4.1'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-sidekiq', '~> 3.0'
  gem 'simplecov', '~> 0.16', require: false
  gem 'webmock', '~> 3.5'
  gem 'parallel_tests', '~> 2.28'
end

group :development do
  gem 'active_record_query_trace', '~> 1.6'
  gem 'annotate', '~> 2.7'
  gem 'better_errors', '~> 2.5'
  gem 'binding_of_caller', '~> 0.7'
  gem 'bullet', '~> 5.9'
  gem 'letter_opener', '~> 1.7'
  gem 'letter_opener_web', '~> 1.3'
  gem 'memory_profiler'
  gem 'rubocop', '~> 0.67', require: false
  gem 'brakeman', '~> 4.5', require: false
  gem 'bundler-audit', '~> 0.6', require: false
  gem 'scss_lint', '~> 0.57', require: false

  gem 'capistrano', '~> 3.11'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-yarn', '~> 2.0'

  gem 'derailed_benchmarks'
  gem 'stackprof'
end

group :production do
  gem 'lograge', '~> 0.10'
  gem 'redis-rails', '~> 5.0'
end

gem 'concurrent-ruby', require: false

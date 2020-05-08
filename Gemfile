# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.5.0', '< 3.0.0'

gem 'pkg-config', '~> 1.4'

gem 'puma', '~> 4.3'
gem 'rails', '~> 5.2.4.2'
gem 'sprockets', '~> 3.7.2'
gem 'thor', '~> 0.20'
gem 'rack', '~> 2.2.2'

gem 'thwait', '~> 0.1.0'
gem 'e2mmap', '~> 0.1.0'

gem 'hamlit-rails', '~> 0.2'
gem 'pg', '~> 1.2'
gem 'makara', '~> 0.4'
gem 'pghero', '~> 2.4'
gem 'dotenv-rails', '~> 2.7'

gem 'aws-sdk-s3', '~> 1.63', require: false
gem 'fog-core', '<= 2.1.0'
gem 'fog-openstack', '~> 0.3', require: false
gem 'paperclip', '~> 6.0'
gem 'paperclip-av-transcoder', '~> 0.6'
gem 'streamio-ffmpeg', '~> 3.0'
gem 'blurhash', '~> 0.1'

gem 'active_model_serializers', '~> 0.10'
gem 'addressable', '~> 2.7'
gem 'bootsnap', '~> 1.4', require: false
gem 'browser'
gem 'charlock_holmes', '~> 0.7.7'
gem 'iso-639'
gem 'chewy', '~> 5.1'
gem 'cld3', '~> 3.3.0'
gem 'devise', '~> 4.7'
gem 'devise-two-factor', '~> 3.1'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.16'
gem 'omniauth-cas', '~> 1.1'
gem 'omniauth-saml', '~> 1.10'
gem 'omniauth', '~> 1.9'

gem 'discard', '~> 1.2'
gem 'doorkeeper', '~> 5.3'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'goldfinger', '~> 2.1'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.7'
gem 'health_check', git: 'https://github.com/ianheggie/health_check', ref: '0b799ead604f900ed50685e9b2d469cd2befba5b'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 4.4'
gem 'http_accept_language', '~> 2.1'
gem 'http_parser.rb', '~> 0.6', git: 'https://github.com/tmm1/http_parser.rb', ref: '54b17ba8c7d8d20a16dfc65d1775241833219cf2', submodules: true
gem 'httplog', '~> 1.4.2'
gem 'idn-ruby', require: 'idn'
gem 'kaminari', '~> 1.2'
gem 'link_header', '~> 0.0'
gem 'mime-types', '~> 3.3.1', require: 'mime/types/columnar'
gem 'nilsimsa', git: 'https://github.com/witgo/nilsimsa', ref: 'fd184883048b922b176939f851338d0a4971a532'
gem 'nokogiri', '~> 1.10'
gem 'nsa', '~> 0.2'
gem 'oj', '~> 3.10'
gem 'ox', '~> 2.13'
gem 'parslet'
gem 'parallel', '~> 1.19'
gem 'posix-spawn', git: 'https://github.com/rtomayko/posix-spawn', ref: '58465d2e213991f8afb13b984854a49fcdcc980c'
gem 'pundit', '~> 2.1'
gem 'premailer-rails'
gem 'rack-attack', '~> 6.3'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'
gem 'rails-i18n', '~> 5.1'
gem 'rails-settings-cached', '~> 0.6'
gem 'redis', '~> 4.1', require: ['redis', 'redis/connection/hiredis']
gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
gem 'rqrcode', '~> 1.1'
gem 'ruby-progressbar', '~> 1.10'
gem 'sanitize', '~> 5.1'
gem 'sidekiq', '~> 6.0'
gem 'sidekiq-scheduler', '~> 3.0'
gem 'sidekiq-unique-jobs', '~> 6.0'
gem 'sidekiq-bulk', '~>0.2.0'
gem 'simple-navigation', '~> 4.1'
gem 'simple_form', '~> 5.0'
gem 'sprockets-rails', '~> 3.2', require: 'sprockets/railtie'
gem 'stoplight', '~> 2.2.0'
gem 'strong_migrations', '~> 0.6'
gem 'tty-command', '~> 0.9', require: false
gem 'tty-prompt', '~> 0.21', require: false
gem 'twitter-text', '~> 1.14'
gem 'tzinfo-data', '~> 1.2019'
gem 'webpacker', '~> 4.2'
gem 'webpush'

gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.1'
gem 'rdf-normalize', '~> 0.4'

group :development, :test do
  gem 'fabrication', '~> 2.21'
  gem 'fuubar', '~> 2.5'
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'pry-byebug', '~> 3.8'
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 4.0'
end

group :production, :test do
  gem 'private_address_check', '~> 0.5'
end

group :test do
  gem 'capybara', '~> 3.31'
  gem 'climate_control', '~> 0.2'
  gem 'faker', '~> 2.11'
  gem 'microformats', '~> 4.2'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-sidekiq', '~> 3.0'
  gem 'simplecov', '~> 0.18', require: false
  gem 'webmock', '~> 3.8'
  gem 'parallel_tests', '~> 2.32'
  gem 'rspec_junit_formatter', '~> 0.4'
end

group :development do
  gem 'active_record_query_trace', '~> 1.7'
  gem 'annotate', '~> 3.1'
  gem 'better_errors', '~> 2.6'
  gem 'binding_of_caller', '~> 0.7'
  gem 'bullet', '~> 6.1'
  gem 'letter_opener', '~> 1.7'
  gem 'letter_opener_web', '~> 1.4'
  gem 'memory_profiler'
  gem 'rubocop', '~> 0.79', require: false
  gem 'rubocop-rails', '~> 2.5', require: false
  gem 'brakeman', '~> 4.8', require: false
  gem 'bundler-audit', '~> 0.6', require: false

  gem 'capistrano', '~> 3.13'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-yarn', '~> 2.0'

  gem 'stackprof'
end

group :production do
  gem 'lograge', '~> 0.11'
  gem 'redis-rails', '~> 5.0'
end

gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false

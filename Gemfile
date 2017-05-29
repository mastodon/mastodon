# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.3.0', '< 2.5.0'

gem 'pkg-config', '~> 1.2'

gem 'puma', '~> 3.8'
gem 'rails', '~> 5.0'
gem 'uglifier', '~> 3.2'

gem 'hamlit-rails', '~> 0.2'
gem 'pg', '~> 0.20'
gem 'pghero', '~> 1.7'
gem 'dotenv-rails', '~> 2.2'

gem 'aws-sdk', '~> 2.9'
gem 'paperclip', '~> 5.1'
gem 'paperclip-av-transcoder', '~> 0.6'

gem 'addressable', '~> 2.5'
gem 'bootsnap'
gem 'cld3', '~> 3.1'
gem 'devise', '~> 4.2'
gem 'devise-two-factor', '~> 3.0'
gem 'doorkeeper', '~> 4.2'
gem 'fast_blank', '~> 1.0'
gem 'goldfinger', '~> 1.2'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.5'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 2.2'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 0.99'
gem 'kaminari', '~> 1.0'
gem 'link_header', '~> 0.0'
gem 'nokogiri', '~> 1.7'
gem 'oj', '~> 3.0'
gem 'ostatus2', '~> 2.0'
gem 'ox', '~> 2.5'
gem 'rabl', '~> 0.13'
gem 'rack-attack', '~> 5.0'
gem 'rack-cors', '~> 0.4', require: 'rack/cors'
gem 'rack-timeout', '~> 0.4'
gem 'rails-i18n', '~> 5.0'
gem 'rails-settings-cached', '~> 0.6'
gem 'redis', '~> 3.3', require: ['redis', 'redis/connection/hiredis']
gem 'rqrcode', '~> 0.10'
gem 'ruby-oembed', '~> 0.12', require: 'oembed'
gem 'sanitize', '~> 4.4'
gem 'sidekiq', '~> 5.0'
gem 'sidekiq-scheduler', '~> 2.1'
gem 'sidekiq-unique-jobs', '~> 5.0'
gem 'simple-navigation', '~> 4.0'
gem 'simple_form', '~> 3.4'
gem 'sprockets-rails', '~> 3.2', require: 'sprockets/railtie'
gem 'statsd-instrument', '~> 2.1'
gem 'twitter-text', '~> 1.14'
gem 'tzinfo-data', '~> 1.2017'
gem 'webpacker', '~> 1.2'

group :development, :test do
  gem 'fabrication', '~> 2.16'
  gem 'fuubar', '~> 2.2'
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 3.6'
end

group :test do
  gem 'capybara', '~> 2.14'
  gem 'faker', '~> 1.7'
  gem 'microformats2', '~> 3.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-sidekiq', '~> 3.0'
  gem 'simplecov', '~> 0.14', require: false
  gem 'webmock', '~> 3.0'
  gem 'parallel_tests', '~> 2.14'
end

group :development do
  gem 'active_record_query_trace', '~> 1.5'
  gem 'annotate', '~> 2.7'
  gem 'better_errors', '~> 2.1'
  gem 'binding_of_caller', '~> 0.7'
  gem 'bullet', '~> 5.5'
  gem 'letter_opener', '~> 1.4'
  gem 'letter_opener_web', '~> 1.3'
  gem 'rubocop', '~> 0.48', require: false
  gem 'brakeman', '~> 3.6', require: false
  gem 'bundler-audit', '~> 0.5', require: false
  gem 'scss_lint', '~> 0.53', require: false

  gem 'capistrano', '~> 3.8'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-yarn', '~> 2.0'
end

group :production do
  gem 'lograge', '~> 0.5'
  gem 'redis-rails', '~> 5.0'
end

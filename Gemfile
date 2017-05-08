# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.3.0', '< 2.5.0'

gem 'pkg-config'

gem 'puma'
gem 'rails', '~> 5.0.2'
gem 'uglifier', '>= 1.3.0'

gem 'hamlit-rails'
gem 'pg'
gem 'pghero'
gem 'dotenv-rails'

gem 'aws-sdk', '>= 2.0'
gem 'paperclip', '~> 5.1'
gem 'paperclip-av-transcoder'

gem 'addressable'
gem 'cld2', require: 'cld'
gem 'devise'
gem 'devise-two-factor'
gem 'doorkeeper'
gem 'fast_blank'
gem 'goldfinger'
gem 'hiredis'
gem 'redis-namespace'
gem 'htmlentities'
gem 'http'
gem 'http_accept_language'
gem 'httplog'
gem 'kaminari'
gem 'link_header'
gem 'nokogiri'
gem 'oj'
gem 'ostatus2', '~> 2.0'
gem 'ox'
gem 'rabl'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-timeout'
gem 'rails-i18n'
gem 'rails-settings-cached'
gem 'redis', '~>3.2', require: ['redis', 'redis/connection/hiredis']
gem 'rqrcode'
gem 'ruby-oembed', require: 'oembed'
gem 'sanitize'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-unique-jobs'
gem 'simple-navigation'
gem 'simple_form'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'statsd-instrument'
gem 'twitter-text'
gem 'tzinfo-data'
gem 'webpacker', '~>1.2'

group :development, :test do
  gem 'fabrication'
  gem 'fuubar'
  gem 'i18n-tasks', '~> 0.9.6'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'faker'
  gem 'microformats2'
  gem 'rails-controller-testing'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'parallel_tests'
end

group :development do
  gem 'active_record_query_trace'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'rubocop', '0.46.0', require: false
  gem 'brakeman', '~> 3.6.0', require: false
  gem 'bundler-audit', '~> 0.4.0', require: false
  gem 'scss_lint', '0.42.2', require: false
  gem 'haml_lint', '~> 0.19.0', require: false

  gem 'capistrano', '3.8.0'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'
end

group :production do
  gem 'lograge'
  gem 'rails_12factor'
  gem 'redis-rails'
end

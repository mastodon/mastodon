# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '~> 5.0.2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'puma'

gem 'hamlit-rails'
gem 'pg'
gem 'pghero'
gem 'dotenv-rails'
gem 'font-awesome-rails'
gem 'best_in_place', '~> 3.0.1'

gem 'paperclip', '~> 5.1'
gem 'paperclip-av-transcoder'
gem 'aws-sdk', '>= 2.0'

gem 'http'
gem 'httplog'
gem 'addressable'
gem 'nokogiri'
gem 'link_header'
gem 'ostatus2'
gem 'goldfinger'
gem 'devise'
gem 'devise-two-factor'
gem 'doorkeeper'
gem 'rabl'
gem 'rqrcode'
gem 'twitter-text'
gem 'ox'
gem 'oj'
gem 'hiredis'
gem 'redis', '~>3.2', require: ['redis', 'redis/connection/hiredis']
gem 'fast_blank'
gem 'htmlentities'
gem 'simple_form'
gem 'will_paginate'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'rails-settings-cached'
gem 'simple-navigation'
gem 'statsd-instrument'
gem 'ruby-oembed', require: 'oembed'
gem 'rack-timeout'
gem 'tzinfo-data'

gem 'react-rails'
gem 'browserify-rails'
gem 'autoprefixer-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'fuubar'
  gem 'fabrication'
  gem 'i18n-tasks', '~> 0.9.6'
end

group :test do
  gem 'faker'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development do
  gem 'rubocop', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'bullet'
  gem 'active_record_query_trace'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'
  gem 'capistrano-faster-assets', '~> 1.0'
end

group :production do
  gem 'rails_12factor'
  gem 'redis-rails'
  gem 'lograge'
end

# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', git: 'https://github.com/rails/rails.git', branch: '5-0-stable'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'puma'

gem 'hamlit-rails'
gem 'pg'
gem 'pghero'
gem 'dotenv-rails'
gem 'font-awesome-rails'

gem 'paperclip', '~> 4.3'
gem 'paperclip-av-transcoder'
gem 'aws-sdk', '< 2.0'

gem 'http'
gem 'httplog'
gem 'addressable'
gem 'nokogiri'
gem 'link_header'
gem 'ostatus2'
gem 'goldfinger'
gem 'devise'
gem 'rails_autolink'
gem 'doorkeeper'
gem 'rabl'
gem 'oj'
gem 'hiredis'
gem 'redis', '~>3.2'
gem 'fast_blank'
gem 'htmlentities'
gem 'simple_form'
gem 'will_paginate'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'sidekiq'
gem 'ledermann-rails-settings'
gem 'pg_search'

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
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'rspec-sidekiq'
end

group :development do
  gem 'rubocop', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'bullet'
  gem 'active_record_query_trace'
end

group :production do
  gem 'rails_12factor'
  gem 'lograge'
  gem 'redis-rails'
end

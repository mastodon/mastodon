# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 2.5.0', '< 3.1.0'

gem 'pkg-config'
gem 'rexml'

gem 'puma'
gem 'rails', '7.0.0.rc1'
gem 'sprockets'
gem 'thor'
gem 'rack'

gem 'hamlit-rails'
gem 'pg'
gem 'makara'
gem 'pghero'
gem 'dotenv-rails'

gem 'aws-sdk-s3', require: false
gem 'fog-core', '<= 2.1.0'
gem 'fog-openstack', require: false
gem 'kt-paperclip'
gem 'blurhash'

gem 'active_model_serializers'
gem 'addressable'
gem 'bootsnap', require: false
gem 'browser'
gem 'charlock_holmes'
gem 'iso-639'
gem 'chewy'
gem 'cld3'
gem 'devise', github: 'heartcombo/devise'
gem 'devise-two-factor'
gem 'thread_safe'

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2'
end

gem 'net-ldap'
gem 'omniauth-cas'
gem 'omniauth-saml'
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'

gem 'color_diff'
gem 'discard'
gem 'doorkeeper'
gem 'ed25519'
gem 'fast_blank'
gem 'fastimage'
gem 'hiredis'
gem 'redis-namespace'
gem 'htmlentities'
gem 'http'
gem 'http_accept_language'
gem 'httplog'
gem 'idn-ruby', require: 'idn'
gem 'kaminari'
gem 'link_header'
gem 'mime-types', require: 'mime/types/columnar'
gem 'nokogiri'
gem 'nsa'
gem 'oj'
gem 'ox'
gem 'parslet'
gem 'posix-spawn'
gem 'pundit'
gem 'premailer-rails'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rails-i18n'
gem 'rails-settings-cached'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'mario-redis-lock', require: 'redis_lock'
gem 'rqrcode'
gem 'ruby-progressbar'
gem 'sanitize'
gem 'scenic'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-unique-jobs'
gem 'sidekiq-bulk'
gem 'simple-navigation'
gem 'simple_form'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'stoplight'
gem 'strong_migrations'
gem 'tty-prompt', require: false
gem 'twitter-text'
gem 'tzinfo-data'
gem 'webpacker'
gem 'webpush'
gem 'webauthn'

gem 'json-ld'
gem 'json-ld-preloaded'
gem 'rdf-normalize'

group :development, :test do
  gem 'fabrication'
  gem 'fuubar'
  gem 'i18n-tasks', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :production, :test do
  gem 'private_address_check'
end

group :test do
  gem 'capybara'
  gem 'climate_control'
  gem 'faker'
  gem 'microformats'
  gem 'rails-controller-testing'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'rspec_junit_formatter'
end

group :development do
  gem 'active_record_query_trace'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem 'bullet'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'memory_profiler'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'

  gem 'stackprof'
end

group :production do
  gem 'lograge'
end

gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false

gem 'xorcist'

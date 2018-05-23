source "http://rubygems.org"

gem 'redis-store', '~> 1.1.0'
gem 'activesupport', '>= 5.0.0.beta1', '< 5.1'

group :development do
  gem 'rake', '~> 10'
  gem 'bundler', '~> 1.3'
  gem 'mocha', '~> 0.14.0'
  gem 'minitest', '~> 5.1'
  gem 'connection_pool', '~> 1.2.0'
  gem 'redis-store-testing'
end

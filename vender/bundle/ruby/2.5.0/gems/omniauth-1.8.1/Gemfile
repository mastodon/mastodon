source 'https://rubygems.org'

gem 'jruby-openssl', '~> 0.9.19', :platforms => :jruby
gem 'rake', '>= 12.0'
gem 'yard', '>= 0.9.11'

group :development do
  gem 'benchmark-ips'
  gem 'kramdown'
  gem 'memory_profiler'
  gem 'pry'
end

group :test do
  gem 'coveralls', :require => false
  gem 'hashie', '>= 3.4.6', '< 3.6.0', :platforms => [:jruby_18]
  gem 'json', '~> 2.0.3', :platforms => %i[jruby_18 jruby_19 ruby_19]
  gem 'mime-types', '~> 3.1', :platforms => [:jruby_18]
  gem 'rack', '>= 1.6.2', :platforms => %i[jruby_18 jruby_19 ruby_19 ruby_20 ruby_21]
  gem 'rack-test'
  gem 'rest-client', '~> 2.0.0', :platforms => [:jruby_18]
  gem 'rspec', '~> 3.5.0'
  gem 'rubocop', '>= 0.47', :platforms => %i[ruby_20 ruby_21 ruby_22 ruby_23 ruby_24]
  gem 'tins', '~> 1.13.0', :platforms => %i[jruby_18 jruby_19 ruby_19]
end

gemspec

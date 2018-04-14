# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "jruby-openssl" if defined? JRUBY_VERSION

group :development do
  gem "guard-rspec", require: false
  gem "pry",         require: false
end

group :development, :test do
  gem "coveralls",         require: false
  gem "rake-compiler",     require: false
  gem "rspec", "~> 3.7",   require: false
  gem "rspec-retry",       require: false
  gem "rubocop", "0.52.1", require: false
end

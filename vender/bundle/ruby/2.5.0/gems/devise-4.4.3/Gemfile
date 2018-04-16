# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rails", "~> 5.1"
gem "omniauth", "~> 1.3"
gem "oauth2"
gem "omniauth-oauth2"
gem "rdoc"

gem "activemodel-serializers-xml", github: "rails/activemodel-serializers-xml"

gem "rails-controller-testing"

gem "responders", "~> 2.1"

group :test do
  gem "omniauth-facebook"
  gem "omniauth-openid"
  gem "webrat", "0.7.3", require: false
  gem "mocha", "~> 1.1", require: false
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcsqlite3-adapter"
  gem "jruby-openssl"
end

platforms :ruby do
  gem "sqlite3"
end

# TODO:
# group :mongoid do
#   gem "mongoid", "~> 4.0.0"
# end

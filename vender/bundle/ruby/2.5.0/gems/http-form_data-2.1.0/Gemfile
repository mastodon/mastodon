# frozen_string_literal: true

source "https://rubygems.org"

gem "rake"

group :development do
  gem "guard"
  gem "guard-rspec", :require => false
  gem "pry"
end

group :test do
  gem "coveralls"
  gem "rspec",      "~> 3.1"
  gem "rubocop",    "= 0.48.1"
  gem "simplecov",  ">= 0.9"
end

group :doc do
  gem "redcarpet", :platform => :mri
  gem "yard"
end

# Specify your gem's dependencies in form_data.gemspec
gemspec

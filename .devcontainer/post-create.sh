#!/bin/bash

set -e # Fail the whole script on first error

# Fetch Ruby gem dependencies
bundle config path 'vendor/bundle'
bundle config with 'development test'
bundle install

# Make Gemfile.lock pristine again
git checkout -- Gemfile.lock

# Fetch Javascript dependencies
yarn --frozen-lockfile

# [re]create, migrate, and seed the test database
RAILS_ENV=test ./bin/rails db:setup

# [re]create, migrate, and seed the development database
RAILS_ENV=development ./bin/rails db:setup

# Precompile assets for development
RAILS_ENV=development ./bin/rails assets:precompile

# Precompile assets for test
RAILS_ENV=test NODE_ENV=tests ./bin/rails assets:precompile

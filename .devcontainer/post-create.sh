#!/bin/bash

set -e # Fail the whole script on first error

gem install bundler -v $(tail -n 1 Gemfile.lock)

# Fetch Ruby gem dependencies
bundle config path 'vendor/bundle'
bundle config with 'development test'
bundle check || bundle install

# Fetch Javascript dependencies
corepack prepare
yarn install --immutable

# [re]create, migrate, and seed the development database
./bin/rails db:setup


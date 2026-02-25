# frozen_string_literal: true

unless ENV.key?('RAILS_ENV')
  abort <<~ERROR # rubocop:disable Rails/Exit
    The RAILS_ENV environment variable is not set.

    Please set it correctly depending on context:

      - Use "production" for a live deployment of the application
      - Use "development" for local feature work
      - Use "test" when running the automated spec suite
  ERROR
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

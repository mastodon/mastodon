if RUBY_ENGINE == 'ruby'
  if ENV['CI']
    require 'coveralls'
    Coveralls::Output.silent = true
    Coveralls.wear! do
      add_filter 'spec/'
    end
  else
    require 'simplecov'
    SimpleCov.start
  end
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../spec/rails_app/config/environment.rb", __FILE__)

require 'support/fixtures/message'
require 'support/fixtures/html'

require 'nokogiri'

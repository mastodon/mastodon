ENV["RAILS_ENV"] = "test"
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
end
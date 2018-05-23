require "rubygems"
require 'bundler/setup'
require 'bundler/gem_tasks'
require "test/unit"

require "rack"
require "rack/test"

Test::Unit::TestCase.class_eval do
  include Rack::Test::Methods
end

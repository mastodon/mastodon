require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/setup'
require 'redis'
require 'redis-store'
require 'pry'

$DEBUG = ENV["DEBUG"] === "true"

Redis::DistributedStore.send(:class_variable_set, :@@timeout, 30)

# http://mentalized.net/journal/2010/04/02/suppress_warnings_from_ruby/
module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

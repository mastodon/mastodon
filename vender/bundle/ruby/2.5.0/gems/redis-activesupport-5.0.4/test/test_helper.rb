require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/setup'
require 'active_support'
require 'active_support/cache/redis_store'

puts "Testing against ActiveSupport v.#{ActiveSupport::VERSION::STRING}"
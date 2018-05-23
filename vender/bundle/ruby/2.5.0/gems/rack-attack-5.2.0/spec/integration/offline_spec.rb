require 'active_support/cache'
require 'redis-activesupport'
require 'dalli'
require_relative '../spec_helper'

OfflineExamples = Minitest::SharedExamples.new do
  it 'should write' do
    @cache.write('cache-test-key', 'foobar', 1)
  end

  it 'should read' do
    @cache.read('cache-test-key')
  end

  it 'should count' do
    @cache.send(:do_count, 'rack::attack::cache-test-key', 1)
  end
end

describe 'when Redis is offline' do
  include OfflineExamples

  before {
    @cache = Rack::Attack::Cache.new
    # Use presumably unused port for Redis client
    @cache.store = ActiveSupport::Cache::RedisStore.new(:host => '127.0.0.1', :port => 3333)
  }
end

describe 'when Memcached is offline' do
  include OfflineExamples

  before {
    Dalli.logger.level = Logger::FATAL

    @cache = Rack::Attack::Cache.new
    @cache.store = Dalli::Client.new('127.0.0.1:22122')
  }

  after {
    Dalli.logger.level = Logger::INFO
  }
end

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
Bundler.require(:default, :test)

require 'rspec'
require 'redis'
require 'logger'

$TESTING=true
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'redis/namespace'

module Helper
  def capture_stderr(io = nil)
    require 'stringio'
    io ||= StringIO.new
    begin
      original, $stderr = $stderr, io
      yield
    rescue Redis::CommandError
      # ignore Redis::CommandError for test and
      # return captured messages
      $stderr.string.chomp
    ensure
      $stderr = original
    end
  end

  def with_env(env = {})
    backup_env = ENV.to_hash.dup
    ENV.update(env)

    yield
  ensure
    ENV.replace(backup_env)
  end

  def silent
    verbose, $VERBOSE = $VERBOSE, false

    begin
      yield
    ensure
      $VERBOSE = verbose
    end
  end

  def with_external_encoding(encoding)
    original_encoding = Encoding.default_external

    begin
      silent { Encoding.default_external = Encoding.find(encoding) }
      yield
    ensure
      silent { Encoding.default_external = original_encoding }
    end
  end

  def try_encoding(encoding, &block)
    if defined?(Encoding)
      with_external_encoding(encoding, &block)
    else
      yield
    end
  end
end

RSpec.configure do |c|
  c.include Helper
end

RSpec::Matchers.define :have_key do |expected|
  match do |redis|
    redis.exists(expected)
  end
end

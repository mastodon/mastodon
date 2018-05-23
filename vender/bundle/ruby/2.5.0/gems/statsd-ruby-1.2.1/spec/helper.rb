require 'bundler/setup'
require 'minitest/autorun'

require 'simplecov'
SimpleCov.start

require 'statsd'
require 'logger'

class FakeUDPSocket
  def initialize
    @buffer = []
  end

  def send(message, *rest)
    @buffer.push [message]
  end

  def recv
    @buffer.shift
  end

  def clear
    @buffer = []
  end

  def to_s
    inspect
  end

  def inspect
    "<FakeUDPSocket: #{@buffer.inspect}>"
  end
end

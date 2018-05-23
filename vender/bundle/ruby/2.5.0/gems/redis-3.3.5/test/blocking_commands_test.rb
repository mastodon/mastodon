# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))
require "lint/blocking_commands"

class TestBlockingCommands < Test::Unit::TestCase

  include Helper::Client
  include Lint::BlockingCommands

  def assert_takes_longer_than_client_timeout
    timeout = OPTIONS[:timeout]
    delay = timeout * 2

    mock(:delay => delay) do |r|
      t1 = Time.now
      yield(r)
      t2 = Time.now

      assert timeout == r.client.timeout
      assert delay <= (t2 - t1)
    end
  end

  def test_blpop_disable_client_timeout
    assert_takes_longer_than_client_timeout do |r|
      assert_equal ["foo", "0"], r.blpop("foo")
    end
  end

  def test_brpop_disable_client_timeout
    assert_takes_longer_than_client_timeout do |r|
      assert_equal ["foo", "0"], r.brpop("foo")
    end
  end

  def test_brpoplpush_disable_client_timeout
    assert_takes_longer_than_client_timeout do |r|
      assert_equal "0", r.brpoplpush("foo", "bar")
    end
  end
end
